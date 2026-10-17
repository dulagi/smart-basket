import from services.basketService { BasketItem, BillLine, StoreDelivery, InventoryRow, OptimizationResult, ItemClassification, initializeBasket, classify_groceries, optimizeBasket, listStoreInventory }
import from services.paymentCards { SavedPaymentCard, listSavedCards, addSavedCard }
import from services.userProfile { BasketProfile, saveDisplayName, getDisplayName }
import ".styles.global.css";
import from "react" { useEffect }
import from "@jac/runtime" { Router, Routes, Route }
import from .components.SmartBasket { SmartBasket }
import from .components.StoreInventory { StoreInventory }
import from .components.AccountLogin { AccountLogin }
import from .components.AccountSignup { AccountSignup }
import from .components.SavedCards { SavedCards }


def:pub app() -> JsxElement {
    has theme: str = "dark";
    async can with entry {
        stored_theme = localStorage.getItem("smart-basket-theme");
        if stored_theme == "light" { theme = "light"; }
        else { theme = "dark"; }
    }
    can with [theme] entry {
        document.documentElement.classList.toggle("light", theme == "light");
        document.documentElement.classList.toggle("dark", theme == "dark");
    }
    def toggle_theme(e: MouseEvent) {
        theme = "light" if theme == "dark" else "dark";
        localStorage.setItem("smart-basket-theme", theme);
    }
    return <Router><div className={"app-theme theme-" + theme}>
        <button type="button" onClick={toggle_theme} className="fixed bottom-4 right-4 z-50 rounded-full border border-white/20 bg-slate-900 px-4 py-2 text-xs font-semibold text-white shadow-lg transition-all hover:-translate-y-0.5 hover:bg-slate-800">{"Switch to light mode" if theme == "dark" else "Switch to dark mode"}</button>
        <Routes>
            <Route path="/" element={<SmartBasket />} />
            <Route path="/login" element={<AccountLogin />} />
            <Route path="/signup" element={<AccountSignup />} />
            <Route path="/account/cards" element={<SavedCards />} />
            <Route path="/stores" element={<StoreInventory />} />
        </Routes>
    </div></Router>;
}
