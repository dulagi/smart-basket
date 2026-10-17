import from services.basketService { BasketItem, OptimizationResult, initializeBasket, optimizeBasket }
import ".styles.global.css";
import from .components.SmartBasket { SmartBasket }


def:pub app() -> JsxElement {
    return <SmartBasket />;
}
