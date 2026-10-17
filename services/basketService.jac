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

obj BillLine {
    has name: str;
    has quantity: float = 1.0;
    has store: str = "";
    has base_price: float = 0.0;
    has item_discount: float = 0.0;
    has line_total: float = 0.0;
    has promo_note: str = "";
}

obj StoreDelivery {
    has store: str;
    has courier: str;
    has charge: float = 0.0;
}

node SavedPaymentCard {
    has nickname: str;
    has brand: str;
    has last_four: str;
}

obj OptimizationResult {
    has items: list[BasketItem] = [];
    has lines: list[BillLine] = [];
    has deliveries: list[StoreDelivery] = [];
    has store: str = "";
    has courier: str = "";
    has card: str = "";
    has subtotal: float = 0.0;
    has item_discounts: float = 0.0;
    has basket_discount: float = 0.0;
    has delivery_charge: float = 0.0;
    has total: float = 0.0;
    has savings: float = 0.0;
    has delivery_days: int = 1;
    has delivery_hours: int = 0;
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

async def:pub optimizeBasket(grocery_text: str, selected_cards: list[str], preferred_stores: list[str], speed_priority: int, delivery_days: int, delivery_hours: int) -> OptimizationResult {
    if len(grocery_text.strip()) == 0 { return OptimizationResult(error="Add at least one grocery item to build your basket."); }
    _ = initializeBasket();
    classified: ClassificationResult;
    try {
        classified = await classify_groceries(grocery_text);
    } except Exception {
        fallback: list[ItemClassification] = [];
        for part in grocery_text.split(",") {
            name = part.strip();
            if len(name) > 0 { fallback = fallback + [ItemClassification(name=name, category="Pantry")]; }
        }
        classified = ClassificationResult(items=fallback);
    }
    if len(classified.items) == 0 { return OptimizationResult(error="No grocery items were recognized."); }

    products: list[BasketItem] = [];
    for classification in classified.items {
        typed_name = classification.name.lower().strip();
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
            products = products + [BasketItem(name=found.name, quantity=quantity, category=classification.category)];
        }
    }
    if len(products) == 0 { return OptimizationResult(error="No matching groceries found. Try rice, milk, eggs, bread, dhal, tomatoes, bananas, tea, sugar, or chicken."); }

    chosen_stores: list[Supermarket] = [];
    for shop in [root -->][?:Supermarket] {
        if len(preferred_stores) == 0 or shop.name in preferred_stores { chosen_stores = chosen_stores + [shop]; }
    }
    if len(chosen_stores) == 0 { return OptimizationResult(error="Select at least one available supermarket."); }

    line_results: list[BillLine] = [];
    store_subtotals: dict[str, float] = {};
    store_discounts: dict[str, float] = {};
    store_cards: dict[str, str] = {};
    subtotal: float = 0.0;
    item_discount_total: float = 0.0;
    savings: float = 0.0;

    for product in products {
        best_item_cost: float = 999999999.0;
        best_line: BillLine | None = None;
        for shop in chosen_stores {
            base_price: float = 0.0;
            list_price: float = 0.0;
            category: str = product.category;
            for grocery in [root -->][?:Grocery] {
                if grocery.name == product.name { base_price = grocery.base_price; category = grocery.category; }
            }
            item_price = base_price;
            for offer in [shop ->:HasOffer:->][?:InventoryOffer] {
                if offer.item_name == product.name { item_price = offer.price; }
            }
            promo_rate: float = 0.0;
            promo_text: str = "Regular price";
            promo_bank: str = "";
            for promo in [shop ->:HasPromotion:->][?:CardPromotion] {
                if promo.bank in selected_cards and (promo.category == "All" or promo.category == category) and promo.discount > promo_rate {
                    promo_rate = promo.discount;
                    promo_text = promo.description;
                    promo_bank = promo.bank;
                }
            }
            discount = item_price * product.quantity * promo_rate;
            payable = item_price * product.quantity - discount;
            delivery_alloc = 0.0;
            for courier in [shop ->:HasCourier:->][?:DeliveryCourier] {
                if courier.cost < 999999999.0 { delivery_alloc = courier.cost; }
            }
            adjusted = payable + delivery_alloc / (len(products) as float);
            if adjusted < best_item_cost {
                best_item_cost = adjusted;
                best_line = BillLine(name=product.name, quantity=product.quantity, store=shop.name, base_price=item_price * product.quantity, item_discount=discount, line_total=payable, promo_note=promo_text);
                _ = list_price;
                store_cards[shop.name] = promo_bank;
            }
        }
        if best_line is not None {
            chosen_line = best_line as BillLine;
            line_results = line_results + [chosen_line];
            subtotal += chosen_line.base_price;
            item_discount_total += chosen_line.item_discount;
            savings += chosen_line.item_discount;
            prior = store_subtotals[chosen_line.store] if chosen_line.store in store_subtotals else 0.0;
            store_subtotals[chosen_line.store] = (prior as float) + chosen_line.line_total;
            prior_discount = store_discounts[chosen_line.store] if chosen_line.store in store_discounts else 0.0;
            store_discounts[chosen_line.store] = (prior_discount as float) + chosen_line.item_discount;
        }
    }

    delivery_lines: list[StoreDelivery] = [];
    delivery_total: float = 0.0;
    best_courier_name: str = "";
    store_names: list[str] = [];
    for line in line_results {
        if not (line.store in store_names) { store_names = store_names + [line.store]; }
    }
    for store_name in store_names {
        courier_cost: float = 999999999.0;
        courier_name: str = "";
        for shop in chosen_stores {
            if shop.name == store_name {
                for courier in [shop ->:HasCourier:->][?:DeliveryCourier] {
                    speed_adjust = (1.0 - (speed_priority as float) / 100.0) * (courier.days as float) * 80.0;
                    candidate_cost = courier.cost + speed_adjust;
                    if candidate_cost < courier_cost { courier_cost = candidate_cost; courier_name = courier.name; }
                }
            }
        }
        if courier_cost < 999999999.0 {
            delivery_total += courier_cost;
            delivery_lines = delivery_lines + [StoreDelivery(store=store_name, courier=courier_name, charge=courier_cost)];
            if best_courier_name == "" { best_courier_name = courier_name; }
        }
    }
    pre_discount_total = subtotal - item_discount_total;
    basket_discount: float = 0.0;
    if "Sampath Bank" in selected_cards { basket_discount = pre_discount_total * 0.10; }
    total = pre_discount_total - basket_discount + delivery_total;
    savings += basket_discount;
    eta = (datetime.now() + timedelta(days=delivery_days, hours=delivery_hours)).strftime("%A, %d %B at %H:%M");
    return OptimizationResult(items=products, lines=line_results, deliveries=delivery_lines, store=", ".join(store_names), courier=best_courier_name, card=", ".join(selected_cards), subtotal=subtotal, item_discounts=item_discount_total, basket_discount=basket_discount, delivery_charge=delivery_total, total=total, savings=savings, delivery_days=delivery_days, delivery_hours=delivery_hours, delivery_date=eta, promo_note="Item and basket discounts applied where available");
}
