import from datetime { datetime, timedelta }

node Grocery {
    has name: str = "";
    has base_price: float = 0.0;
    has category: str = "Pantry";
}

node Supermarket {
    has name: str = "";
}

node InventoryOffer {
    has item_name: str = "";
    has price: float = 0.0;
}

node CardPromotion {
    has bank: str = "";
    has description: str = "";
    has category: str = "";
    has discount: float = 0.0;
}

node DeliveryCourier {
    has name: str = "";
    has cost: float = 0.0;
    has days: int = 1;
}

edge HasOffer: Supermarket --> InventoryOffer {}
edge OfferFor: InventoryOffer --> Grocery {}
edge HasPromotion: Supermarket --> CardPromotion {}
edge HasCourier: Supermarket --> DeliveryCourier {}

obj BasketItem {
    has name: str;
    has quantity: float = 1.0;
    has unit: str = "";
    has category: str = "Pantry";
}

obj OptimizationResult {
    has items: list[BasketItem] = [];
    has store: str = "";
    has courier: str = "";
    has card: str = "";
    has total: float = 0.0;
    has savings: float = 0.0;
    has delivery_days: int = 1;
    has delivery_date: str = "";
    has promo_note: str = "";
    has error: str = "";
}

obj ItemClassification {
    has name: str;
    has category: str;
}

obj ClassificationResult {
    has items: list[ItemClassification] = [];
}

sem ItemClassification.name = "The normalized grocery item name, preserving quantity if useful.";
sem ItemClassification.category = "Exactly Perishable or Pantry. Fresh produce, dairy, meat and bread are Perishable. Dry goods and household staples are Pantry.";
sem ClassificationResult.items = "One classification for each comma-separated grocery item supplied.";

def classify_groceries(grocery_text: str) -> ClassificationResult by llm(temperature=0.1, max_tokens=500);
sem classify_groceries = "Categorize every grocery list entry for delivery planning. Return Perishable for food that should arrive promptly, otherwise Pantry. Do not omit entries.";
sem classify_groceries.grocery_text = "User's comma-separated grocery list, including quantities.";


def:pub initializeBasket() -> bool {
    if len([root -->][?:Supermarket]) > 0 { return True; }
    rice = root ++> Grocery(name="rice", base_price=420.0, category="Pantry");
    milk = root ++> Grocery(name="milk", base_price=520.0, category="Perishable");
    eggs = root ++> Grocery(name="eggs", base_price=640.0, category="Perishable");
    bread = root ++> Grocery(name="bread", base_price=280.0, category="Perishable");
    dhal = root ++> Grocery(name="dhal", base_price=390.0, category="Pantry");
    tomatoes = root ++> Grocery(name="tomatoes", base_price=360.0, category="Perishable");
    bananas = root ++> Grocery(name="bananas", base_price=300.0, category="Perishable");
    tea = root ++> Grocery(name="tea", base_price=850.0, category="Pantry");
    sugar = root ++> Grocery(name="sugar", base_price=310.0, category="Pantry");
    chicken = root ++> Grocery(name="chicken", base_price=1250.0, category="Perishable");
    groceries: list[Grocery] = [rice, milk, eggs, bread, dhal, tomatoes, bananas, tea, sugar, chicken];

    keells = root ++> Supermarket(name="Keells");
    cargills = root ++> Supermarket(name="Cargills Food City");
    ar = root ++> Supermarket(name="Arpico Supercentre");
    stores: list[Supermarket] = [keells, cargills, ar];
    prices: list[list[float]] = [
        [420.0, 520.0, 640.0, 280.0, 390.0, 360.0, 300.0, 850.0, 310.0, 1250.0],
        [435.0, 495.0, 660.0, 275.0, 375.0, 390.0, 320.0, 820.0, 295.0, 1320.0],
        [405.0, 540.0, 620.0, 300.0, 400.0, 340.0, 285.0, 880.0, 325.0, 1190.0]
    ];
    for (store_index, shop) in enumerate(stores) {
        for (item_index, grocery) in enumerate(groceries) {
            offer = InventoryOffer(item_name=grocery.name, price=prices[store_index][item_index]);
            shop +>:HasOffer:+> offer;
            offer +>:OfferFor:+> grocery;
        }
    }
    promo1 = root ++> CardPromotion(bank="Commercial Bank", description="20% off fresh produce", category="Perishable", discount=0.20);
    promo2 = root ++> CardPromotion(bank="HNB", description="15% off pantry essentials", category="Pantry", discount=0.15);
    promo3 = root ++> CardPromotion(bank="Sampath Bank", description="10% off your grocery basket", category="All", discount=0.10);
    keells +>:HasPromotion:+> promo1;
    cargills +>:HasPromotion:+> promo2;
    ar +>:HasPromotion:+> promo3;
    flash = root ++> DeliveryCourier(name="PickMe Flash", cost=380.0, days=1);
    uber = root ++> DeliveryCourier(name="Uber Direct", cost=520.0, days=1);
    keells +>:HasCourier:+> flash;
    keells +>:HasCourier:+> uber;
    cargills +>:HasCourier:+> flash;
    cargills +>:HasCourier:+> uber;
    ar +>:HasCourier:+> flash;
    ar +>:HasCourier:+> uber;
    return True;
}

walker:pub optimizeBasket {
    has grocery_text: str = "";
    has selected_cards: list[str] = [];
    has preferred_stores: list[str] = [];
    has speed_priority: int = 50;

    async can optimize with Root entry {
        if len(self.grocery_text.strip()) == 0 {
            report OptimizationResult(error="Add at least one grocery item to build your basket.");
            disengage;
        }
        _ = initializeBasket();
        classified: ClassificationResult;
        try {
            classified = await classify_groceries(self.grocery_text);
        } except Exception {
            parts = self.grocery_text.split(",");
            fallback: list[ItemClassification] = [];
            for part in parts {
                name = part.strip();
                if len(name) > 0 { fallback = fallback + [ItemClassification(name=name, category="Pantry")]; }
            }
            classified = ClassificationResult(items=fallback);
        }
        if len(classified.items) == 0 {
            report OptimizationResult(error="No grocery items were recognized. Try a comma-separated list.");
            disengage;
        }

        best_total: float = 999999999.0;
        best_store: str = "";
        best_courier: str = "";
        best_card: str = "Cash on delivery";
        best_savings: float = 0.0;
        best_days: int = 1;
        best_note: str = "";
        best_items: list[BasketItem] = [];
        for shop in [root -->][?:Supermarket] {
            if len(self.preferred_stores) > 0 and not (shop.name in self.preferred_stores) { continue; }
            subtotal: float = 0.0;
            original: float = 0.0;
            selected_items: list[BasketItem] = [];
            for classification in classified.items {
                typed_name = classification.name.lower();
                quantity: float = 1.0;
                if typed_name.startswith("2kg ") { quantity = 2.0; typed_name = typed_name[4:]; }
                elif typed_name.startswith("1kg ") { typed_name = typed_name[4:]; }
                elif typed_name.startswith("1l ") { typed_name = typed_name[3:]; }
                elif typed_name.startswith("1l") { typed_name = typed_name[2:]; }
                elif typed_name.startswith("2l ") { quantity = 2.0; typed_name = typed_name[3:]; }
                matched: Grocery | None = None;
                for product in [root -->][?:Grocery] {
                    if product.name in typed_name or typed_name in product.name { matched = product; }
                }
                if matched is not None {
                found = matched as Grocery;
                item_price: float = found.base_price;
                for inventory in [edge shop ->:HasOffer:->][?:InventoryOffer] {
                    if inventory.item_name == found.name { item_price = inventory.price; }
                }
                original += found.base_price * quantity;
                subtotal += item_price * quantity;
                selected_items = selected_items + [BasketItem(name=found.name, quantity=quantity, category=classification.category)];
                }
            }
            for courier in [shop ->:HasCourier:->][?:DeliveryCourier] {
                for promotion in [shop ->:HasPromotion:->][?:CardPromotion] {
                    eligible_card = promotion.bank in self.selected_cards;
                    if promotion.bank == "Commercial Bank" and promotion.category == "Perishable" {
                        _ = 0;
                    }
                    discount_total: float = 0.0;
                    if eligible_card {
                        for selected in selected_items {
                            if promotion.category == "All" or promotion.category == selected.category {
                                for inventory in [edge shop ->:HasOffer:->][?:InventoryOffer] {
                                    if inventory.item_name == selected.name {
                                        discount_total += inventory.price * selected.quantity * promotion.discount;
                                    }
                                }
                            }
                        }
                    }
                    final_total = subtotal - discount_total + courier.cost;
                    speed_cost = (1.0 - (self.speed_priority as float) / 100.0) * (courier.days as float) * 80.0;
                    adjusted_total = final_total + speed_cost;
                    if adjusted_total < best_total {
                        best_total = adjusted_total;
                        best_store = shop.name;
                        best_courier = courier.name;
                        best_card = promotion.bank if eligible_card and discount_total > 0.0 else "Cash on delivery";
                        best_savings = original + 520.0 - final_total;
                        best_days = courier.days;
                        best_note = promotion.description if eligible_card and discount_total > 0.0 else "No eligible bank offer applied";
                        best_items = selected_items;
                    }
                }
            }
        }
        if best_store == "" {
            report OptimizationResult(error="No matching store was found. Adjust your preferred store selection.");
            disengage;
        }
        eta = (datetime.now() + timedelta(days=best_days)).strftime("%A, %d %B");
        report OptimizationResult(items=best_items, store=best_store, courier=best_courier, card=best_card, total=best_total, savings=best_savings, delivery_days=best_days, delivery_date=eta, promo_note=best_note);
    }
}
