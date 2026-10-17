import from services.basketService { BasketItem, OptimizationResult, ItemClassification, initializeBasket, classify_groceries, optimizeBasket }

import ".styles.global.css";
import from .components.SmartBasket { SmartBasket }


def:pub app() -> JsxElement {
    return <SmartBasket />;
}
