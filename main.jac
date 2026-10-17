import from services.basketService { BasketItem, BillLine, StoreDelivery, OptimizationResult, ItemClassification, initializeBasket, classify_groceries, optimizeBasket }
import from services.paymentCards { SavedPaymentCard, listSavedCards, addSavedCard }
import from services.basketService { optimizeBasket }

import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.SmartBasket { SmartBasket }
import from .components.AccountLogin { AccountLogin }
import from .components.SavedCards { SavedCards }


def:pub app() -> JsxElement {
    return <Router><Routes>
        <Route path="/" element={<SmartBasket />} />
        <Route path="/login" element={<AccountLogin />} />
        <Route path="/account/cards" element={<SavedCards />} />
    </Routes></Router>;
}
