import from datetime { datetime, timedelta }

node Grocery {
    has name: str = "";
    has base_price: float = 0.0;
    has category: str = "Pantry";
}
node Supermarket { has name: str = ""; }
node InventoryOffer {
    has item_name: str = "";
    has price: float = 0.0;
    has promo_price: float = 0.0;
    has promo_text: str = "";
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
obj InventoryRow {
    has name: str;
    has category: str;
    has store: str;
    has price: float = 0.0;
    has promo_price: float = 0.0;
    has promo_text: str = "";
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
obj ItemClassification { has name: str; has category: str; }
obj ClassificationResult { has items: list[ItemClassification] = []; }
sem ItemClassification.name = "The normalized grocery item name, preserving quantity if useful.";
sem ItemClassification.category = "Exactly Perishable or Pantry. Fresh produce, dairy, meat and bread are Perishable. Dry goods and household staples are Pantry.";
sem ClassificationResult.items = "One classification for each comma-separated grocery item supplied.";
def classify_groceries(grocery_text: str) -> ClassificationResult by llm(temperature=0.1, max_tokens=500);
sem classify_groceries = "Categorize every grocery list entry for delivery planning. Return Perishable for food that should arrive promptly, otherwise Pantry. Do not omit entries.";
sem classify_groceries.grocery_text = "User's comma-separated grocery list, including quantities.";


def:pub initializeBasket() -> bool {
    catalog = [g for g in [root -->][?:Grocery] if g.name == "Carrot (1kg)"];
    if len(catalog) > 0 { return True; }
    groceries: list[Grocery] = [
        Grocery(name="Carrot (1kg)", base_price=420.0, category="Fresh Produce"),
        Grocery(name="Leeks (1kg)", base_price=380.0, category="Fresh Produce"),
        Grocery(name="Potato (1kg)", base_price=340.0, category="Fresh Produce"),
        Grocery(name="Onion (1kg)", base_price=520.0, category="Fresh Produce"),
        Grocery(name="Tomato (1kg)", base_price=310.0, category="Fresh Produce"),
        Grocery(name="Green Chilli (250g)", base_price=180.0, category="Fresh Produce"),
        Grocery(name="Banana (1kg)", base_price=360.0, category="Fresh Produce"),
        Grocery(name="Papaya (1kg)", base_price=260.0, category="Fresh Produce"),
        Grocery(name="Fish (500g)", base_price=1650.0, category="Meat & Fish"),
        Grocery(name="Chicken (1kg)", base_price=1250.0, category="Meat & Fish"),
        Grocery(name="Sausages (500g)", base_price=820.0, category="Meat & Fish"),
        Grocery(name="Eggs (Pack of 10)", base_price=460.0, category="Dairy & Eggs"),
        Grocery(name="Milk (1L)", base_price=490.0, category="Dairy & Eggs"),
        Grocery(name="Butter (200g)", base_price=780.0, category="Dairy & Eggs"),
        Grocery(name="Cheese (200g)", base_price=920.0, category="Dairy & Eggs"),
        Grocery(name="Yoghurt (Pack of 4)", base_price=320.0, category="Dairy & Eggs"),
        Grocery(name="Rice (5kg)", base_price=1420.0, category="Pantry"),
        Grocery(name="Basmati Rice (5kg)", base_price=2850.0, category="Pantry"),
        Grocery(name="Dhal (1kg)", base_price=340.0, category="Pantry"),
        Grocery(name="Sugar (1kg)", base_price=265.0, category="Pantry"),
        Grocery(name="Coconut Oil (1L)", base_price=1150.0, category="Pantry"),
        Grocery(name="Tea (400g)", base_price=680.0, category="Pantry"),
        Grocery(name="Biscuits (Large pack)", base_price=390.0, category="Snacks"),
        Grocery(name="Washing Powder (1kg)", base_price=540.0, category="Household"),
        Grocery(name="Soap (Pack of 4)", base_price=480.0, category="Household")
    ];
    for grocery in groceries { root ++> grocery; }
    store_names: list[str] = ["Keells", "Arpico", "Cargills"];
    stores: list[Supermarket] = [];
    for name in store_names {
        found: Supermarket | None = None;
        for existing in [root -->][?:Supermarket] { if existing.name == name { found = existing; } }
        if found is None { stores = stores + [root ++> Supermarket(name=name)]; }
        else { stores = stores + [found as Supermarket]; }
    }
    prices: list[list[float]] = [
        [420.0,380.0,340.0,520.0,310.0,180.0,360.0,260.0,1650.0,1250.0,820.0,460.0,490.0,780.0,920.0,320.0,1420.0,2850.0,340.0,265.0,1150.0,680.0,390.0,540.0,480.0],
        [390.0,360.0,330.0,510.0,290.0,170.0,380.0,240.0,1700.0,1220.0,850.0,450.0,480.0,760.0,890.0,320.0,1390.0,2790.0,330.0,260.0,1120.0,660.0,380.0,520.0,470.0],
        [410.0,390.0,350.0,540.0,320.0,190.0,350.0,250.0,1680.0,1240.0,830.0,470.0,490.0,790.0,930.0,310.0,1420.0,2890.0,340.0,265.0,1180.0,690.0,390.0,550.0,490.0]
    ];
    promo_prices: list[list[float]] = [
        [340.0,0.0,0.0,450.0,250.0,0.0,0.0,200.0,0.0,1100.0,0.0,0.0,0.0,680.0,0.0,0.0,0.0,2450.0,290.0,0.0,0.0,0.0,330.0,0.0,420.0],
        [0.0,300.0,0.0,440.0,0.0,130.0,310.0,0.0,0.0,1080.0,0.0,390.0,0.0,0.0,800.0,0.0,1280.0,0.0,0.0,0.0,980.0,570.0,0.0,430.0,0.0],
        [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,270.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    ];
    promos: list[list[str]] = [
        ["Keells 20% off fresh veg","","","Keells & Arpico seasonal deal","Keells fresh deal","","","Keells daily pick","","Keells & Arpico meat markdown","","","","Keells breakfast offer","","","","Keells premium rice deal","Keells bulk markdown","","","","Keells tea-time combo","","Keells hygiene pack offer"],
        ["","Arpico weekly harvest drop","","Keells & Arpico seasonal deal","","Arpico flash discount","Arpico fruit saver","","","Keells & Arpico meat markdown","","Arpico weekend price drop","","","Arpico dairy special","","Arpico staple grains discount","","","","Arpico cooking oil special","Arpico beverage deal","","Arpico home care discount",""],
        ["","","","","","","","","","","","","","","","Cargills dairy promo","","","","","","","","",""]
    ];
    for (store_index, shop) in enumerate(stores) {
        for (item_index, grocery) in enumerate(groceries) {
            attached: bool = False;
            for existing_offer in [shop ->:HasOffer:->][?:InventoryOffer] { if existing_offer.item_name == grocery.name { attached = True; } }
            if not attached {
                offer = InventoryOffer(item_name=grocery.name, price=prices[store_index][item_index], promo_price=promo_prices[store_index][item_index], promo_text=promos[store_index][item_index]);
                shop +>:HasOffer:+> offer;
                offer +>:OfferFor:+> grocery;
            }
        }
        for courier in [root -->][?:DeliveryCourier] { shop +>:HasCourier:+> courier; }
    }
    return True;
}

def:pub listStoreInventory(store_name: str) -> list[InventoryRow] {
    _ = initializeBasket();
    rows: list[InventoryRow] = [];
    for shop in [root -->][?:Supermarket] {
        if store_name == "All stores" or shop.name == store_name {
            for offer in [shop ->:HasOffer:->][?:InventoryOffer] {
                category = "";
                for item in [root -->][?:Grocery] { if item.name == offer.item_name { category = item.category; } }
                rows = rows + [InventoryRow(name=offer.item_name, category=category, store=shop.name, price=offer.price, promo_price=offer.promo_price, promo_text=offer.promo_text)];
            }
        }
    }
    return rows;
}

async def:pub optimizeBasket(grocery_text: str, selected_cards: list[str], preferred_stores: list[str], speed_priority: int, delivery_days: int, delivery_hours: int) -> OptimizationResult {
    if len(grocery_text.strip()) == 0 { return OptimizationResult(error="Add at least one grocery item to build your basket."); }
    _ = initializeBasket();
    classified: ClassificationResult;
    try { classified = await classify_groceries(grocery_text); }
    except Exception {
        fallback: list[ItemClassification] = [];
        for part in grocery_text.split(",") { name = part.strip(); if len(name) > 0 { fallback = fallback + [ItemClassification(name=name, category="Pantry")]; } }
        classified = ClassificationResult(items=fallback);
    }
    if len(classified.items) == 0 { return OptimizationResult(error="No grocery items were recognized."); }
    products: list[BasketItem] = [];
    for classification in classified.items {
        needle = classification.name.lower().strip();
        quantity: float = 1.0;
        if needle.startswith("2kg ") { quantity = 2.0; needle = needle[4:]; }
        elif needle.startswith("1kg ") { needle = needle[4:]; }
        elif needle.startswith("1l ") { needle = needle[3:]; }
        elif needle.startswith("2l ") { quantity = 2.0; needle = needle[3:]; }
        needle = needle.strip();
        matched: Grocery | None = None;
        for item in [root -->][?:Grocery] {
            normalized_name = item.name.lower();
            if normalized_name.startswith(needle + " (") or normalized_name == needle { matched = item; }
        }
        if matched is not None { product = matched as Grocery; products = products + [BasketItem(name=product.name, quantity=quantity, category=product.category)]; }
    }
    if len(products) == 0 { return OptimizationResult(error="No matching catalog items. Open Browse store inventory to see all items."); }
    candidates: list[Supermarket] = [];
    for shop in [root -->][?:Supermarket] { if len(preferred_stores) == 0 or shop.name in preferred_stores { candidates = candidates + [shop]; } }
    lines: list[BillLine] = [];
    subtotal: float = 0.0;
    item_savings: float = 0.0;
    for product in products {
        lowest_cost: float = 999999999.0;
        winning_line: BillLine | None = None;
        for shop in candidates {
            regular: float = 0.0;
            sale: float = 0.0;
            description: str = "Regular price";
            for offer in [shop ->:HasOffer:->][?:InventoryOffer] {
                if offer.item_name == product.name {
                    regular = offer.price;
                    sale = offer.promo_price;
                    description = offer.promo_text;
                }
            }
            payable_price = sale if sale > 0.0 else regular;
            discount = regular * product.quantity - payable_price * product.quantity;
            delivery_estimate: float = 380.0 / (len(products) as float);
            if payable_price * product.quantity + delivery_estimate < lowest_cost {
                lowest_cost = payable_price * product.quantity + delivery_estimate;
                winning_line = BillLine(name=product.name, quantity=product.quantity, store=shop.name, base_price=regular * product.quantity, item_discount=discount, line_total=payable_price * product.quantity, promo_note=description);
            }
        }
        if winning_line is not None {
            final_line = winning_line as BillLine;
            lines = lines + [final_line];
            subtotal += final_line.base_price;
            item_savings += final_line.item_discount;
        }
    }
    store_names: list[str] = [];
    for line in lines { if not (line.store in store_names) { store_names = store_names + [line.store]; } }
    deliveries: list[StoreDelivery] = [];
    delivery_total: float = 0.0;
    courier_label: str = "";
    for shop in candidates {
        if shop.name in store_names {
            selected_courier: str = "PickMe Flash";
            fee: float = 380.0;
            for courier in [shop ->:HasCourier:->][?:DeliveryCourier] { if courier.cost < fee { selected_courier = courier.name; fee = courier.cost; } }
            deliveries = deliveries + [StoreDelivery(store=shop.name, courier=selected_courier, charge=fee)];
            delivery_total += fee;
            if courier_label == "" { courier_label = selected_courier; }
        }
    }
    total_discount: float = 0.0;
    if "Sampath Bank" in selected_cards { total_discount = (subtotal - item_savings) * 0.10; }
    total = subtotal - item_savings - total_discount + delivery_total;
    eta = (datetime.now() + timedelta(days=delivery_days, hours=delivery_hours)).strftime("%A, %d %B at %H:%M");
    return OptimizationResult(items=products, lines=lines, deliveries=deliveries, store=", ".join(store_names), courier=courier_label, card=", ".join(selected_cards), subtotal=subtotal, item_discounts=item_savings, basket_discount=total_discount, delivery_charge=delivery_total, total=total, savings=item_savings + total_discount, delivery_days=delivery_days, delivery_hours=delivery_hours, delivery_date=eta, promo_note="Store promo prices applied");
}
