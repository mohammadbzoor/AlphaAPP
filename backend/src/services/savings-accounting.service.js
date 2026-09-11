'use strict';

const { db } = require('../config/database');
const { AppError } = require('../utils/app-error');

class SavingsAccountingService {
  static async getCycleSavingsPlan(userId, cycleId) {
    const [rows] = await db.execute(
      `SELECT csa.savings_amount, csa.emergency_fund_amount, csa.emergency_fund_rate, csa.total_goal_allocations, csa.unallocated_savings_amount
       FROM cycle_savings_allocations csa
       JOIN financial_cycles fc ON fc.id = csa.cycle_id
       WHERE csa.cycle_id = ? AND fc.user_id = ? LIMIT 1`,
      [cycleId, userId]
    );

    if (rows.length === 0) {
      const [snapRows] = await db.execute(
        `SELECT cas.savings_target 
         FROM cycle_allocation_snapshots cas
         JOIN financial_cycles fc ON fc.id = cas.cycle_id
         WHERE cas.cycle_id = ? AND fc.user_id = ? LIMIT 1`,
        [cycleId, userId]
      );
      const plannedSavings = snapRows.length > 0 ? Number(snapRows[0].savings_target || 0) : 0;
      const plannedEmergencyFund = Math.round(plannedSavings * 0.10);

      const [goalsRows] = await db.execute(
        `SELECT COALESCE(SUM(planned_contribution), 0) AS total 
         FROM goals 
         WHERE user_id = ? AND status = 'active' AND is_system_managed = FALSE AND goal_type != 'emergency_fund'`,
        [userId]
      );
      const goalsTotal = Number(goalsRows[0].total);
      const plannedGoalAllocations = Math.min(goalsTotal, Math.max(0, plannedSavings - plannedEmergencyFund));
      const unallocatedSavings = Math.max(0, plannedSavings - plannedEmergencyFund - plannedGoalAllocations);

      return {
        plannedSavings,
        emergencyFundPercentage: 10,
        plannedEmergencyFund,
        plannedGoalAllocations,
        unallocatedSavings
      };
    }

    const plan = rows[0];
    const plannedSavings = Number(plan.savings_amount || 0);
    const emergencyFundPercentage = Number(plan.emergency_fund_rate ?? 10);
    let plannedEmergencyFund = Number(plan.emergency_fund_amount || 0);
    let plannedGoalAllocations = Number(plan.total_goal_allocations || 0);

    if (plannedEmergencyFund === 0 && plannedSavings > 0 && emergencyFundPercentage > 0) {
      plannedEmergencyFund = Math.round(plannedSavings * (emergencyFundPercentage / 100));
    }

    if (plannedGoalAllocations === 0 && plannedSavings > 0) {
      const [goalsRows] = await db.execute(
        `SELECT COALESCE(SUM(planned_contribution), 0) AS total 
         FROM goals 
         WHERE user_id = ? AND status = 'active' AND is_system_managed = FALSE AND goal_type != 'emergency_fund'`,
        [userId]
      );
      const goalsTotal = Number(goalsRows[0].total);
      const availableForGoals = Math.max(0, plannedSavings - plannedEmergencyFund);
      if (goalsTotal > 0 && availableForGoals > 0) {
        plannedGoalAllocations = Math.min(goalsTotal, availableForGoals);
      }
    }

    const unallocatedSavings = Math.max(0, plannedSavings - plannedEmergencyFund - plannedGoalAllocations);

    return {
      plannedSavings,
      emergencyFundPercentage,
      plannedEmergencyFund,
      plannedGoalAllocations,
      unallocatedSavings
    };
  }

  static async getActualGoalContributions(userId, cycleId) {
    const [rows] = await db.execute(
      `SELECT COALESCE(SUM(gt.amount), 0) AS total
       FROM goal_transactions gt
       JOIN goals g ON g.id = gt.goal_id
       WHERE gt.user_id = ? AND ? = ? AND gt.transaction_type = 'contribution'
         AND (g.goal_type != 'emergency_fund' OR g.is_system_managed = FALSE)`,
      [userId, cycleId, cycleId]
    );
    return Number(rows[0].total);
  }

  static async getEmergencyFundFundedThisCycle(userId, cycleId) {
    const [rows] = await db.execute(
      `SELECT COALESCE(SUM(gt.amount), 0) AS total
       FROM goal_transactions gt
       JOIN goals g ON g.id = gt.goal_id
       WHERE gt.user_id = ? AND ? = ? AND gt.transaction_type = 'contribution'
         AND g.goal_type = 'emergency_fund' AND g.is_system_managed = TRUE`,
      [userId, cycleId, cycleId]
    );
    return Number(rows[0].total);
  }

  static async getUnallocatedSavingsActual(userId, cycleId) {
    const [rows] = await db.execute(
      `SELECT COALESCE(SUM(amount), 0) AS total
       FROM transactions
       WHERE user_id = ? AND cycle_id = ? AND transaction_type = 'saving' AND budget_bucket = 'savings' AND status = 'confirmed'`,
      [userId, cycleId]
    );
    return Number(rows[0].total);
  }

  static async getCycleSavingsActuals(userId, cycleId) {
    const actualGoalContributions = await this.getActualGoalContributions(userId, cycleId);
    const emergencyFundFundedThisCycle = await this.getEmergencyFundFundedThisCycle(userId, cycleId);
    const unallocatedSavingsActual = await this.getUnallocatedSavingsActual(userId, cycleId);
    const totalSavingsActual = actualGoalContributions + emergencyFundFundedThisCycle + unallocatedSavingsActual;

    return {
      actualGoalContributions,
      emergencyFundFundedThisCycle,
      unallocatedSavingsActual,
      totalSavingsActual
    };
  }

  static async getEmergencyFundBalance(userId) {
    const [rows] = await db.execute(
      `SELECT current_balance, target_amount
       FROM goals
       WHERE user_id = ? AND goal_type = 'emergency_fund' AND is_system_managed = TRUE
       LIMIT 1`,
      [userId]
    );
    
    if (rows.length === 0) {
      return { emergencyFundBalance: 0, emergencyFundTarget: 0 };
    }

    return {
      emergencyFundBalance: Number(rows[0].current_balance || 0),
      emergencyFundTarget: Number(rows[0].target_amount || 0)
    };
  }

  static async getSettlementSavingsState(userId, cycleId) {
    const plan = await this.getCycleSavingsPlan(userId, cycleId);
    const actuals = await this.getCycleSavingsActuals(userId, cycleId);
    const ef = await this.getEmergencyFundBalance(userId);

    return {
      plan,
      actuals,
      ef
    };
  }

  static async getGoalBalanceConsistency(userId, goalId) {
    const [goalRows] = await db.execute(
      `SELECT current_balance FROM goals WHERE id = ? AND user_id = ? LIMIT 1`,
      [goalId, userId]
    );

    if (goalRows.length === 0) {
      throw new AppError('Goal not found', 404, 'GOAL_NOT_FOUND');
    }

    const cachedBalance = Number(goalRows[0].current_balance || 0);

    const [ledgerRows] = await db.execute(
      `SELECT
         COALESCE(SUM(CASE WHEN transaction_type IN ('contribution', 'adjustment', 'reallocation_in') THEN amount ELSE 0 END), 0) -
         COALESCE(SUM(CASE WHEN transaction_type IN ('withdrawal', 'reallocation_out', 'execution') THEN amount ELSE 0 END), 0) AS ledger_balance
       FROM goal_transactions
       WHERE goal_id = ? AND user_id = ?`,
      [goalId, userId]
    );

    const ledgerBalance = Number(ledgerRows[0].ledger_balance || 0);
    const difference = cachedBalance - ledgerBalance;
    const isConsistent = difference === 0;

    return {
      cachedBalance,
      ledgerBalance,
      difference,
      isConsistent
    };
  }
}

module.exports = { SavingsAccountingService };
