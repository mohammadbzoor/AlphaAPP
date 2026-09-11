const { asyncHandler } = require('../utils/async-handler');
const { N8nService } = require('../services/n8n.service');
const { normalizeReceiptAnalysisResponse } = require('../utils/n8n-response.helper');
const { AppError } = require('../utils/app-error');

class ReceiptsController {
  static analyze = asyncHandler(async (req, res) => {
    console.log('FILE EXISTS:', !!req.file);
    console.log('FIELDNAME:', req.file?.fieldname);

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No receipt image uploaded',
        data: null,
        meta: null
      });
    }

    const n8nResponse = await N8nService.forwardToWebhook(req.file, 'image');

    let normalizedData;
    try {
      normalizedData = normalizeReceiptAnalysisResponse(n8nResponse);

      if (!Array.isArray(normalizedData) || normalizedData.length === 0) {
        normalizedData = [{
          amount: 0,
          currency: 'JOD',
          description: 'Receipt Expense',
          category: 'other',
          sourceType: 'image',
          transactionType: 'expense'
        }];
      }

      const transactions = normalizedData.map((item) => {
        const itemObj = (item && typeof item === 'object') ? item : {};
        const parsedAmount = Number(itemObj.amount ?? itemObj.total ?? itemObj.totalAmount ?? 0);
        const validAmount = isNaN(parsedAmount) || !isFinite(parsedAmount) || parsedAmount < 0 ? 0 : parsedAmount;

        return {
          amount: validAmount,
          currency: itemObj.currency || 'JOD',
          description: itemObj.description || itemObj.merchant || itemObj.storeName || itemObj.store_name || 'Receipt Expense',
          category: itemObj.category || 'other',
          transactionType: itemObj.transactionType || 'expense',
          ...itemObj,
          sourceType: itemObj.sourceType || itemObj.source_type || 'image',
        };
      });

      console.log(`RECEIPT_CONTROLLER normalizedType=array`);
      console.log(`RECEIPT_CONTROLLER transactionCount=${transactions.length}`);
      console.log(`RECEIPT_CONTROLLER responseShape=normalized_transactions`);
      console.log(`RECEIPT_CONTROLLER statusCode=200`);

      return res.status(200).json({
        success: true,
        data: {
          sourceType: 'image',
          transactions: transactions
        },
        meta: {
          transactionCount: transactions.length,
          requiresReview: true
        }
      });
    } catch (err) {
      throw err;
    }
  });
}

module.exports = { ReceiptsController };
