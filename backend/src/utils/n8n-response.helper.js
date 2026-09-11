const { AppError } = require('./app-error');

function isTransactionCandidate(obj) {
    if (!obj || typeof obj !== 'object' || Array.isArray(obj)) return false;
    
    const amountVal = obj.amount ?? obj.total ?? obj.totalAmount ?? obj.price ?? obj.sum;
    const numAmount = Number(amountVal);
    const hasValidAmount = !isNaN(numAmount) && isFinite(numAmount) && numAmount >= 0;

    const recognizedFields = [
        'description', 'date', 'transactionDate', 'bucket', 'category', 
        'paymentMethod', 'payment_method', 'confidence', 'sourceType', 
        'source_type', 'transactionType', 'transaction_type', 'merchant', 
        'store', 'storeName', 'store_name', 'items', 'text'
    ];

    let fieldCount = 0;
    for (const field of recognizedFields) {
        if (obj[field] !== undefined && obj[field] !== null) {
            fieldCount++;
        }
    }

    if (hasValidAmount || fieldCount >= 1) {
        return true;
    }
    return false;
}

function normalizeReceiptAnalysisResponse(value, depth = 0) {
    if (depth > 3) {
        throw new AppError('The receipt analysis response could not be processed.', 502, 'RECEIPT_ANALYSIS_INVALID_RESPONSE');
    }

    // 1. Axios response
    if (value && value.status && value.headers && value.config && value.data !== undefined) {
        return normalizeReceiptAnalysisResponse(value.data, depth + 1);
    }

    // 2. Buffer
    if (Buffer.isBuffer(value)) {
        return normalizeReceiptAnalysisResponse(value.toString('utf8'), depth + 1);
    }

    // 3. String
    if (typeof value === 'string') {
        let trimmed = value.trim();
        if (trimmed.charCodeAt(0) === 0xFEFF) {
            trimmed = trimmed.slice(1);
        }
        if (trimmed.startsWith('```json')) {
            const endIdx = trimmed.lastIndexOf('```');
            if (endIdx > 7) trimmed = trimmed.substring(7, endIdx).trim();
        } else if (trimmed.startsWith('```')) {
            const endIdx = trimmed.lastIndexOf('```');
            if (endIdx > 3) trimmed = trimmed.substring(3, endIdx).trim();
        }
        
        let parsed;
        try {
            parsed = JSON.parse(trimmed);
        } catch (e) {
            // Return raw text as a candidate description if JSON parsing fails
            return [{
                amount: 0,
                currency: 'JOD',
                description: trimmed.slice(0, 100),
                category: 'other',
                sourceType: 'image',
                transactionType: 'expense'
            }];
        }
        return normalizeReceiptAnalysisResponse(parsed, depth + 1);
    }

    // 4. Array
    if (Array.isArray(value)) {
        if (value.length > 0 && value[0] && typeof value[0] === 'object' && !Array.isArray(value[0])) {
            const first = value[0];
            if (first.output !== undefined) return normalizeReceiptAnalysisResponse(first.output, depth + 1);
            if (first.data !== undefined) return normalizeReceiptAnalysisResponse(first.data, depth + 1);
            if (first.result !== undefined) return normalizeReceiptAnalysisResponse(first.result, depth + 1);
            if (first.receipt !== undefined) return normalizeReceiptAnalysisResponse(first.receipt, depth + 1);
            if (first.transactions !== undefined) return normalizeReceiptAnalysisResponse(first.transactions, depth + 1);
        }
        return value;
    }

    // 5-8. Object with envelope
    if (value && typeof value === 'object') {
        if (value.transactions !== undefined) return normalizeReceiptAnalysisResponse(value.transactions, depth + 1);
        if (value.data !== undefined) return normalizeReceiptAnalysisResponse(value.data, depth + 1);
        if (value.output !== undefined) return normalizeReceiptAnalysisResponse(value.output, depth + 1);
        if (value.result !== undefined) return normalizeReceiptAnalysisResponse(value.result, depth + 1);
        if (value.receipt !== undefined) return normalizeReceiptAnalysisResponse(value.receipt, depth + 1);
        if (value.response !== undefined) return normalizeReceiptAnalysisResponse(value.response, depth + 1);

        // 9. Direct single transaction object or candidate
        if (isTransactionCandidate(value)) {
            const amountVal = Number(value.amount ?? value.total ?? value.totalAmount ?? value.price ?? value.sum ?? 0);
            return [{
                amount: isNaN(amountVal) || !isFinite(amountVal) || amountVal < 0 ? 0 : amountVal,
                currency: value.currency || 'JOD',
                description: value.description || value.merchant || value.storeName || value.store_name || value.text || 'Receipt Expense',
                category: value.category || 'other',
                merchant: value.merchant || value.storeName || value.store_name,
                sourceType: 'image',
                transactionType: 'expense',
                ...value
            }];
        }

        // Fallback for any non-empty object
        const amountVal = Number(value.amount ?? value.total ?? value.totalAmount ?? 0);
        return [{
            amount: isNaN(amountVal) || !isFinite(amountVal) || amountVal < 0 ? 0 : amountVal,
            currency: value.currency || 'JOD',
            description: value.description || value.merchant || value.storeName || value.store_name || 'Receipt Expense',
            category: value.category || 'other',
            sourceType: 'image',
            transactionType: 'expense',
            ...value
        }];
    }

    // 10. Default fallback list
    return [{
        amount: 0,
        currency: 'JOD',
        description: 'Receipt Expense',
        category: 'other',
        sourceType: 'image',
        transactionType: 'expense'
    }];
}

module.exports = { normalizeReceiptAnalysisResponse, isTransactionCandidate };
