sv import from ..services.basketService { OptimizationResult, optimizeBasket }
import from .ui.button { Button }
import from .ui.card { Card, CardContent, CardDescription, CardHeader, CardTitle }
import from .ui.input { Input }
import from .ui.badge { Badge }
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { ShoppingBag01Icon, SparklesIcon, DeliveryTruck01Icon, CreditCardIcon, CheckmarkCircle02Icon }


def:pub SmartBasket() -> JsxElement {
    has grocery_text: str = "2kg rice, 1L milk, eggs, tomatoes, bread";
    has basket_items: list[str] = ["2kg rice", "1L milk", "eggs", "tomatoes", "bread"];
    has result: OptimizationResult | None = None;
    has loading: bool = False;
    has error_message: str = "";
    has cards: list[str] = ["Commercial Bank", "HNB", "Sampath Bank", "Cash on delivery"];
    has selected_cards: list[str] = ["Commercial Bank", "HNB", "Cash on delivery"];
    has stores: list[str] = ["Keells", "Cargills Food City", "Arpico Supercentre"];
    has selected_store: str = "All stores";
    has speed_priority: int = 45;

    def handle_text(e: ChangeEvent) { grocery_text = e.target.value; }
    def handle_store(e: ChangeEvent) { selected_store = e.target.value; }
    def handle_speed(e: ChangeEvent) { speed_priority = int(e.target.value); }
    def handle_cards(e: ChangeEvent) {
        card = e.target.value;
        if card in selected_cards { selected_cards = [item for item in selected_cards if item != card]; }
        else { selected_cards = selected_cards + [card]; }
    }
    def handle_add(e: MouseEvent) {
        new_items = grocery_text.split(",");
        basket_items = [item.strip() for item in new_items if len(item.strip()) > 0];
        result = None;
        error_message = "";
    }
    async def handle_optimize -> None {
        loading = True;
        error_message = "";
        store_choices: list[str] = [];
        if selected_store != "All stores" { store_choices = [selected_store]; }
        try {
            response = await optimizeBasket(grocery_text, selected_cards, store_choices, speed_priority);
            if len(response.reports) > 0 {
                result = response.reports[0] as OptimizationResult;
                if result.error != "" { error_message = result.error; result = None; }
            } else { error_message = "The basket planner returned no itinerary. Please try again."; }
        } except Exception {
            error_message = "We could not optimize this basket. Please try again.";
        }
        loading = False;
    }
    def handle_example(e: MouseEvent) {
        grocery_text = "2kg rice, 1L milk, eggs, tomatoes, bread";
        basket_items = grocery_text.split(",");
        result = None;
        error_message = "";
    }

    return <div className="min-h-screen bg-muted/40 text-foreground">
        <header className="border-b bg-background">
            <div className="mx-auto flex h-16 max-w-7xl items-center justify-between gap-4 px-4 sm:px-6">
                <div className="flex items-center gap-3">
                    <div className="flex size-10 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-sm"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div>
                    <div><p className="text-base font-semibold tracking-tight">Smart Basket</p><p className="text-xs text-muted-foreground">Your smarter grocery run</p></div>
                </div>
                <Badge variant="secondary" className="hidden sm:inline-flex">Mock stores · Live optimization</Badge>
            </div>
        </header>
        <main className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-8 sm:px-6 lg:py-10">
            <div className="flex flex-wrap items-end justify-between gap-4">
                <div className="flex max-w-2xl flex-col gap-2">
                    <p className="text-sm font-medium text-primary">Grocery planning, simplified</p>
                    <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">A better basket starts here.</h1>
                    <p className="text-sm leading-relaxed text-muted-foreground sm:text-base">Compare mocked supermarket prices, card promotions, and delivery fees to find your lowest-cost grocery plan.</p>
                </div>
                <div className="flex items-center gap-2 rounded-xl border bg-card px-4 py-3 shadow-sm">
                    <div className="flex size-9 items-center justify-center rounded-lg bg-primary/10 text-primary"><HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-4" /></div>
                    <div><p className="text-sm font-medium">AI basket planner</p><p className="text-xs text-muted-foreground">Perishable-aware scheduling</p></div>
                </div>
            </div>
            <div className="grid gap-6 lg:grid-cols-5">
                <section className="flex flex-col gap-5 lg:col-span-3">
                    <Card className="shadow-sm">
                        <CardHeader><CardTitle>Your grocery list</CardTitle><CardDescription>Separate items with commas. Try rice, milk, eggs, bread, dhal, tomatoes, bananas, tea, sugar, or chicken.</CardDescription></CardHeader>
                        <CardContent className="flex flex-col gap-4">
                            <label htmlFor="grocery-list" className="text-sm font-medium">Items for this basket</label>
                            <textarea id="grocery-list" value={grocery_text} onChange={handle_text} rows={4} placeholder="2kg rice, 1L milk, eggs" className="flex w-full resize-y rounded-lg border border-input bg-background px-3 py-3 text-sm shadow-xs outline-none placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring" />
                            <div className="flex flex-wrap items-center justify-between gap-3">
                                <p className="text-xs text-muted-foreground">{str(len(basket_items))} items in your list</p>
                                <Button variant="outline" size="sm" onClick={handle_add}>Update basket</Button>
                            </div>
                            <div className="flex flex-wrap gap-2">
                                {for (index, item) in enumerate(basket_items) {
                                    if len(item.strip()) > 0 {
                                        <Badge key={str(index)} variant="secondary" className="px-3 py-1">{item.strip()}</Badge>
                                    }
                                }}
                            </div>
                        </CardContent>
                    </Card>
                    <Card className="shadow-sm">
                        <CardHeader><CardTitle>Shopping preferences</CardTitle><CardDescription>Choose the payment options and stores to compare.</CardDescription></CardHeader>
                        <CardContent className="flex flex-col gap-6">
                            <div className="flex flex-col gap-3">
                                <div className="flex items-center gap-2"><HugeiconsIcon icon={CreditCardIcon} strokeWidth={2} className="size-4 text-primary" /><p className="text-sm font-medium">Payment cards</p></div>
                                <div className="grid gap-2 sm:grid-cols-2">
                                    {for card in cards {
                                        <label key={card} className="flex cursor-pointer items-center gap-3 rounded-lg border bg-background px-3 py-2.5 text-sm transition-colors hover:bg-muted/50">
                                            <input type="checkbox" value={card} checked={card in selected_cards} onChange={handle_cards} className="size-4 accent-primary" />{card}
                                        </label>
                                    }}
                                </div>
                            </div>
                            <div className="grid gap-5 sm:grid-cols-2">
                                <div className="flex flex-col gap-2"><label htmlFor="store-choice" className="text-sm font-medium">Preferred supermarket</label><select id="store-choice" value={selected_store} onChange={handle_store} className="h-10 rounded-lg border border-input bg-background px-3 text-sm shadow-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"><option>All stores</option>{for store in stores { <option key={store}>{store}</option> }}</select></div>
                                <div className="flex flex-col gap-2"><div className="flex items-center justify-between"><label htmlFor="speed-priority" className="text-sm font-medium">Delivery priority</label><span className="text-xs tabular-nums text-muted-foreground">{str(speed_priority)}% speed</span></div><input id="speed-priority" type="range" min="0" max="100" step="5" value={str(speed_priority)} onChange={handle_speed} className="mt-2 w-full accent-primary" /><div className="flex justify-between text-xs text-muted-foreground"><span>Save more</span><span>Arrive sooner</span></div></div>
                            </div>
                            <Button onClick={handle_optimize} disabled={loading} className="h-11 w-full shadow-sm"><HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-4" />{ "Find my best basket" if not loading else "Comparing stores and offers..." }</Button>
                            {if error_message != "" { <p role="alert" className="text-sm text-destructive">{error_message}</p> }}
                        </CardContent>
                    </Card>
                </section>
                <section className="flex flex-col gap-5 lg:col-span-2">
                    <Card className="overflow-hidden border-primary/20 shadow-sm">
                        <CardHeader className="bg-primary/5"><div className="flex items-center gap-3"><div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary"><HugeiconsIcon icon={DeliveryTruck01Icon} strokeWidth={2} className="size-5" /></div><div><CardTitle>Your optimized plan</CardTitle><CardDescription>Lowest net cost across mock stores</CardDescription></div></div></CardHeader>
                        <CardContent className="flex flex-col gap-5 pt-5">
                            {if result is None {
                                <div className="flex flex-col items-center gap-3 rounded-xl border border-dashed bg-muted/30 px-5 py-10 text-center">
                                    <div className="flex size-12 items-center justify-center rounded-full bg-background text-primary shadow-sm"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div>
                                    <div><p className="font-medium">Your plan is ready to be made</p><p className="mt-1 text-sm text-muted-foreground">Add your list and let Smart Basket compare every option.</p></div>
                                    <Button variant="outline" size="sm" onClick={handle_example}>Load example basket</Button>
                                </div>
                            } else {
                                <div className="flex flex-col gap-5">
                                    <div className="flex items-end justify-between gap-3"><div><p className="text-xs text-muted-foreground">Estimated total</p><p className="text-3xl font-semibold tracking-tight tabular-nums">Rs. {"{:.2f}".format(result.total)}</p></div><Badge variant="secondary" className="text-primary">Save Rs. {"{:.2f}".format(result.savings)}</Badge></div>
                                    <div className="grid grid-cols-2 gap-3">
                                        <div className="rounded-lg border bg-background p-3"><p className="text-xs text-muted-foreground">Shop at</p><p className="mt-1 font-medium">{result.store}</p></div>
                                        <div className="rounded-lg border bg-background p-3"><p className="text-xs text-muted-foreground">Pay with</p><p className="mt-1 font-medium">{result.card}</p></div>
                                    </div>
                                    <div className="rounded-lg border bg-background p-4"><div className="mb-3 flex items-center justify-between"><p className="font-medium">Delivery itinerary</p><Badge variant="outline">{str(result.delivery_days)} day</Badge></div><div className="flex items-start gap-3"><div className="mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary"><HugeiconsIcon icon={CheckmarkCircle02Icon} strokeWidth={2} className="size-4" /></div><div className="min-w-0"><p className="text-sm font-medium">{result.delivery_date}</p><p className="text-sm text-muted-foreground">{result.courier} · {result.store}</p><p className="mt-1 text-xs text-muted-foreground">{result.promo_note}</p></div></div></div>
                                    <div><p className="mb-2 text-sm font-medium">In this delivery</p><div className="flex flex-col gap-2">{for (index, item) in enumerate(result.items) { <div key={str(index)} className="flex items-center justify-between gap-3 border-b pb-2 last:border-0"><span className="text-sm capitalize">{item.name}{" × " + str(item.quantity) if item.quantity > 1.0 else ""}</span><Badge variant="outline" className="text-xs">{item.category}</Badge></div> }}</div></div>
                                    <p className="text-xs text-muted-foreground">Savings estimated against regular shelf prices and standard delivery.</p>
                                </div>
                            }}
                        </CardContent>
                    </Card>
                    <div className="rounded-xl border bg-card p-4 shadow-sm"><div className="flex items-start gap-3"><div className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"><HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-4" /></div><div><p className="text-sm font-medium">Fresh first, savings next</p><p className="mt-1 text-sm leading-relaxed text-muted-foreground">Perishables are flagged for prompt delivery. Pantry goods can wait for a promotion day. Every store, card offer, and courier fee shown is mocked for this demo.</p></div></div></div>
                </section>
            </div>
        </main>
    </div>;
}
