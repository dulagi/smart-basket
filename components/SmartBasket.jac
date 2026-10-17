sv import from ..services.basketService { OptimizationResult, optimizeBasket }
sv import from ..services.paymentCards { SavedPaymentCard, listSavedCards }
import from "@jac/runtime" { Link, useNavigate, jacIsLoggedIn }
import from .ui.button { Button }
import from .ui.card { Card, CardContent, CardDescription, CardHeader, CardTitle }
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
    has saved_cards: list[SavedPaymentCard] = [];
    has selected_cards: list[str] = ["Commercial Bank", "HNB", "Cash on delivery"];
    has stores: list[str] = ["Keells", "Cargills Food City", "Arpico Supercentre"];
    has selected_stores: list[str] = ["Keells", "Cargills Food City", "Arpico Supercentre"];
    has speed_priority: int = 45;
    has delivery_days: int = 1;
    has delivery_hours: int = 0;

    async can with entry {
        if jacIsLoggedIn() {
            try { saved_cards = await listSavedCards(); }
            except Exception { saved_cards = []; }
        }
    }
    def handle_text(e: ChangeEvent) { grocery_text = e.target.value; }
    def handle_store(e: ChangeEvent) {
        store = e.target.value;
        if store in selected_stores { selected_stores = [item for item in selected_stores if item != store]; }
        else { selected_stores = selected_stores + [store]; }
    }
    def handle_speed(e: ChangeEvent) { speed_priority = int(e.target.value); }
    def handle_days(e: ChangeEvent) { delivery_days = int(e.target.value); }
    def handle_hours(e: ChangeEvent) { delivery_hours = int(e.target.value); }
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
        try {
            offer_banks = [card for card in selected_cards if card in cards];
            for saved in saved_cards {
                saved_label = saved.nickname + " · " + saved.brand + " ending " + saved.last_four;
                if saved_label in selected_cards and not (saved.bank in offer_banks) { offer_banks = offer_banks + [saved.bank]; }
            }
            candidate = await optimizeBasket(grocery_text, offer_banks, selected_stores, speed_priority, delivery_days, delivery_hours);
            if candidate.error != "" { error_message = candidate.error; result = None; }
            else { result = candidate; }
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

    return <div className="sb-app min-h-screen text-foreground">
        <header className="sticky top-0 z-20 border-b border-white/10 bg-slate-950/80 backdrop-blur-xl">
            <div className="mx-auto flex min-h-16 max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-2 sm:flex-nowrap sm:px-6">
                <div className="flex items-center gap-3">
                    <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-400 text-slate-950 shadow-[0_0_28px_rgba(52,211,153,.28)]"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div>
                    <div><p className="text-base font-semibold tracking-tight text-white">Smart Basket</p><p className="text-xs text-slate-400">Agentic grocery intelligence</p></div>
                </div>
                <div className="flex items-center gap-3"><Link to="/account/cards" className="text-xs font-medium text-cyan-200 transition-colors hover:text-white">Saved cards</Link><Link to="/login" className="text-xs font-medium text-slate-400 transition-colors hover:text-white">Sign in</Link><div className="flex items-center gap-2 rounded-full border border-emerald-300/20 bg-emerald-300/10 px-3 py-1.5 text-xs font-medium text-emerald-200"><span className="size-1.5 animate-pulse rounded-full bg-emerald-300" /> Local market simulation</div></div>
            </div>
        </header>
        <main className="mx-auto flex w-full max-w-7xl flex-col gap-7 px-4 py-7 sm:px-6 lg:py-10">
            <div className="relative overflow-hidden rounded-3xl border border-white/10 bg-slate-900/70 px-5 py-7 shadow-2xl shadow-black/20 backdrop-blur-xl sm:px-8 sm:py-9">
                <div className="pointer-events-none absolute -right-14 -top-24 size-72 rounded-full bg-cyan-400/10 blur-3xl" />
                <div className="relative flex flex-wrap items-end justify-between gap-6">
                    <div className="flex max-w-3xl flex-col gap-3">
                        <p className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.22em] text-emerald-300"><HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-4" /> Smarter shopping starts here</p>
                        <h1 className="text-balance text-3xl font-semibold leading-tight tracking-tight text-white sm:text-5xl">A better basket, <span className="text-emerald-300">by design.</span></h1>
                        <p className="max-w-2xl text-sm leading-relaxed text-slate-400 sm:text-base">Compare simulated supermarket prices, card promotions, and delivery fees. Your agent finds the lowest net cost.</p>
                    </div>
                    <div className="flex items-center gap-3 rounded-2xl border border-cyan-300/15 bg-slate-950/50 px-4 py-3 shadow-lg shadow-cyan-950/20 transition-transform duration-300 hover:-translate-y-1">
                        <div className="flex size-10 items-center justify-center rounded-xl bg-cyan-300/10 text-cyan-200"><HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-5" /></div>
                        <div><p className="text-sm font-semibold text-white">AI basket planner</p><p className="text-xs text-slate-400">Perishable-aware scheduling</p></div>
                    </div>
                </div>
            </div>

            <div className="grid gap-5 lg:grid-cols-12 lg:items-start">
                <section className="grid gap-5 sm:grid-cols-2 lg:col-span-7">
                    <Card className="sb-glass border-white/10 bg-slate-900/65 shadow-xl shadow-black/20 transition-all duration-300 hover:border-emerald-300/25 hover:shadow-emerald-950/30 sm:col-span-2">
                        <CardHeader><CardTitle className="text-white">Build your basket</CardTitle><CardDescription className="text-slate-400">Separate your items with commas. Try rice, milk, eggs, bread, dhal, tomatoes, bananas, tea, sugar, or chicken.</CardDescription></CardHeader>
                        <CardContent className="flex flex-col gap-4">
                            <label htmlFor="grocery-list" className="text-sm font-medium text-slate-200">Grocery list</label>
                            <textarea id="grocery-list" value={grocery_text} onChange={handle_text} rows={4} placeholder="2kg rice, 1L milk, eggs" className="w-full resize-y rounded-xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white shadow-inner outline-none transition-all duration-200 placeholder:text-slate-600 focus:border-emerald-300/50 focus:ring-2 focus:ring-emerald-300/15" />
                            <div className="flex flex-wrap items-center justify-between gap-3"><p className="text-xs text-slate-500">{str(len(basket_items))} items in your list</p><Button variant="outline" size="sm" onClick={handle_add} className="border-white/10 bg-white/5 text-slate-200 transition-all duration-200 hover:border-emerald-300/30 hover:bg-emerald-300/10 hover:text-emerald-100">Update basket</Button></div>
                            <div className="flex flex-wrap gap-2">{for (index, item) in enumerate(basket_items) { if len(item.strip()) > 0 { <Badge key={str(index)} variant="secondary" className="border border-white/5 bg-white/5 px-3 py-1 text-slate-300">{item.strip()}</Badge> } }}</div>
                        </CardContent>
                    </Card>

                    <Card className="sb-glass border-white/10 bg-slate-900/65 shadow-xl shadow-black/20 transition-all duration-300 hover:border-cyan-300/20 sm:col-span-2">
                        <CardHeader><CardTitle className="text-white">Tune your strategy</CardTitle><CardDescription className="text-slate-400">Tell the agent which payment methods and stores to compare.</CardDescription></CardHeader>
                        <CardContent className="flex flex-col gap-6">
                            <div className="flex flex-col gap-3">
                                <div className="flex items-center gap-2 text-slate-200"><HugeiconsIcon icon={CreditCardIcon} strokeWidth={2} className="size-4 text-cyan-200" /><p className="text-sm font-medium">Payment methods</p></div>
                                <div className="grid gap-2 sm:grid-cols-2">{for card in cards {
                                    <label key={card} className={"group flex cursor-pointer items-center gap-3 rounded-xl border px-3 py-3 text-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-emerald-300/30 hover:bg-emerald-300/5 " + ("border-emerald-300/35 bg-emerald-300/[0.08] text-emerald-50 shadow-[0_0_20px_rgba(52,211,153,.06)]" if card in selected_cards else "border-white/10 bg-slate-950/35 text-slate-300")}>
                                        <input type="checkbox" value={card} checked={card in selected_cards} onChange={handle_cards} className="size-4 accent-emerald-300" /><span className="flex-1">{card}</span>{card in selected_cards and <span className="text-xs text-emerald-300">Selected</span>}
                                    </label>
                                }}
                                {for saved in saved_cards {
                                    saved_label = saved.nickname + " · " + saved.brand + " ending " + saved.last_four;
                                    <label key={saved.brand + saved.last_four + saved.nickname} className={"group flex cursor-pointer items-center gap-3 rounded-xl border px-3 py-3 text-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-emerald-300/30 hover:bg-emerald-300/5 " + ("border-emerald-300/35 bg-emerald-300/[0.08] text-emerald-50" if saved_label in selected_cards else "border-white/10 bg-slate-950/35 text-slate-300")}><input type="checkbox" value={saved_label} checked={saved_label in selected_cards} onChange={handle_cards} className="size-4 accent-emerald-300" /><span>{saved_label}</span></label>
                                }}
                                <div className="rounded-lg border border-cyan-300/10 bg-cyan-300/[0.04] px-3 py-2 text-xs leading-relaxed text-slate-400">Mock offers: Commercial Bank, 20% off perishables · HNB, 15% off pantry · Sampath Bank, 10% off basket. Select a matching bank/card to apply eligible offers.</div>
                                {if not jacIsLoggedIn() { <Link to="/login" className="text-xs text-cyan-200 hover:text-white">Sign in to load account cards</Link> }}
                            </div>
                            </div>
                            <div className="flex flex-col gap-3"><div className="flex items-center justify-between"><label className="text-sm font-medium text-slate-200">Supermarkets to compare</label><span className="text-xs text-slate-500">Select multiple or leave all selected</span></div><div className="grid gap-2 sm:grid-cols-3">{for store in stores { <label key={store} className={"flex cursor-pointer items-center gap-2 rounded-xl border px-3 py-2.5 text-xs transition-all hover:border-emerald-300/30 " + ("border-emerald-300/35 bg-emerald-300/[0.08] text-emerald-50" if store in selected_stores else "border-white/10 bg-slate-950/35 text-slate-400")}><input type="checkbox" value={store} checked={store in selected_stores} onChange={handle_store} className="size-4 accent-emerald-300" />{store}</label> }}</div></div>
                            <div className="grid gap-5 sm:grid-cols-2"><div className="flex flex-col gap-2"><div className="flex items-center justify-between"><label htmlFor="speed-priority" className="text-sm font-medium text-slate-200">Delivery priority</label><span className="rounded-full bg-cyan-300/10 px-2 py-1 text-xs tabular-nums text-cyan-200">{str(speed_priority)}% speed</span></div><input id="speed-priority" type="range" min="0" max="100" step="5" value={str(speed_priority)} onChange={handle_speed} className="sb-range mt-2 w-full cursor-pointer transition-all duration-200" /><div className="flex justify-between text-xs text-slate-500"><span>Lowest price</span><span>Fastest delivery</span></div></div><div className="grid grid-cols-2 gap-3"><div className="flex flex-col gap-2"><label htmlFor="delivery-days" className="text-sm font-medium text-slate-200">Delivery in days</label><input id="delivery-days" type="number" min="0" max="7" value={str(delivery_days)} onChange={handle_days} className="h-10 w-full rounded-xl border border-white/10 bg-slate-950/65 px-3 text-sm text-white outline-none focus:border-cyan-300/40" /></div><div className="flex flex-col gap-2"><label htmlFor="delivery-hours" className="text-sm font-medium text-slate-200">Extra hours</label><input id="delivery-hours" type="number" min="0" max="23" value={str(delivery_hours)} onChange={handle_hours} className="h-10 w-full rounded-xl border border-white/10 bg-slate-950/65 px-3 text-sm text-white outline-none focus:border-cyan-300/40" /></div></div></div>
                            <button type="button" onClick={handle_optimize} disabled={loading} className="group inline-flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-emerald-300 px-4 text-sm font-semibold text-slate-950 shadow-[0_0_28px_rgba(52,211,153,.18)] transition-all duration-300 hover:-translate-y-0.5 hover:bg-emerald-200 hover:shadow-[0_0_36px_rgba(52,211,153,.30)] disabled:pointer-events-none disabled:opacity-60">
                                {if loading { <span className="sb-radar"><span /></span> } else { <HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-4 transition-transform duration-300 group-hover:rotate-12" /> }}
                                {"Agent negotiating local prices..." if loading else "Find my best basket"}
                            </button>
                            {if error_message != "" { <p role="alert" className="rounded-lg border border-rose-300/20 bg-rose-400/5 px-3 py-2 text-sm text-rose-200">{error_message}</p> }}
                        </CardContent>
                    </Card>
                </section>

                <section className="flex flex-col gap-5 lg:col-span-5">
                    <Card className="sb-glass overflow-hidden border-emerald-300/20 bg-slate-900/75 shadow-xl shadow-emerald-950/15 transition-all duration-300 hover:border-emerald-300/35">
                        <CardHeader className="border-b border-white/5 bg-gradient-to-r from-emerald-300/[0.09] to-cyan-300/[0.04]"><div className="flex items-center gap-3"><div className="flex size-10 items-center justify-center rounded-xl bg-emerald-300/10 text-emerald-200"><HugeiconsIcon icon={DeliveryTruck01Icon} strokeWidth={2} className="size-5" /></div><div><CardTitle className="text-white">Your optimized plan</CardTitle><CardDescription className="text-slate-400">Lowest net cost across simulated stores</CardDescription></div><div className="ml-auto rounded-full border border-emerald-300/20 bg-emerald-300/10 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-emerald-200">Agent result</div></div></CardHeader>
                        <CardContent className="flex flex-col gap-5 p-5">
                            {if loading {
                                <div className="flex min-h-64 flex-col items-center justify-center gap-5 rounded-2xl border border-cyan-300/15 bg-slate-950/45 p-6 text-center">
                                    <div className="sb-radar sb-radar-lg"><span /></div><div><p className="font-medium text-white">Agent negotiating local prices...</p><p className="mt-1 text-sm text-slate-400">Comparing inventory, selected card offers, and delivery fees.</p></div>
                                </div>
                            } elif result is None {
                                <div className="flex min-h-64 flex-col items-center justify-center gap-4 rounded-2xl border border-dashed border-white/10 bg-slate-950/35 px-5 py-10 text-center">
                                    <div className="flex size-12 items-center justify-center rounded-full border border-emerald-300/15 bg-emerald-300/[0.07] text-emerald-200"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div>
                                    <div><p className="font-medium text-white">Your receipt is waiting</p><p className="mt-1 text-sm text-slate-400">Run the agent to see your best store, offer, and delivery plan.</p></div>
                                    <Button variant="outline" size="sm" onClick={handle_example} className="border-white/10 bg-white/5 text-slate-200 transition-all duration-200 hover:border-emerald-300/30 hover:bg-emerald-300/10 hover:text-emerald-100">Load example basket</Button>
                                </div>
                            } else {
                                <div className="sb-receipt flex flex-col gap-5 rounded-2xl border border-white/10 bg-slate-950/45 p-4 sm:p-5">
                                    <div className="flex flex-wrap items-end justify-between gap-3 border-b border-dashed border-white/15 pb-4"><div><p className="text-xs uppercase tracking-[0.16em] text-slate-500">Estimated total</p><p className="mt-1 text-3xl font-semibold tracking-tight tabular-nums text-white">Rs. {"{:.2f}".format(result.total)}</p></div><div className="rounded-xl border border-emerald-300/25 bg-emerald-300/10 px-3 py-2 text-right"><p className="text-[10px] font-semibold uppercase tracking-wider text-emerald-200">You saved</p><p className="text-lg font-semibold tabular-nums text-emerald-200">Rs. {"{:.2f}".format(result.savings)}</p></div></div>
                                    <div className="grid grid-cols-2 gap-3"><div className="rounded-xl border border-white/8 bg-white/[0.03] p-3"><p className="text-[10px] uppercase tracking-wider text-slate-500">Stores in this run</p><p className="mt-1 text-sm font-semibold text-white">{result.store}</p></div><div className="rounded-xl border border-white/8 bg-white/[0.03] p-3"><p className="text-[10px] uppercase tracking-wider text-slate-500">Payment</p><p className="mt-1 text-sm font-semibold text-white">{result.card}</p></div></div>
                                    <div className="rounded-xl border border-white/8 bg-white/[0.025] p-4"><div className="mb-3 flex items-center justify-between"><p className="text-sm font-semibold text-white">Itemized receipt</p><Badge variant="outline" className="border-cyan-300/20 bg-cyan-300/5 text-cyan-200">{str(len(result.lines))} lines</Badge></div><div className="flex flex-col gap-2">{for (index, line) in enumerate(result.lines) { <div key={str(index)} className="flex flex-col gap-1 border-b border-white/5 pb-2"><div className="flex items-center justify-between gap-2"><span className="text-sm capitalize text-slate-200">{line.name} × {str(line.quantity)}</span><span className="text-sm tabular-nums text-white">Rs. {"{:.2f}".format(line.line_total)}</span></div><div className="flex flex-wrap justify-between gap-1 text-xs text-slate-500"><span>{line.store} · Rs. {"{:.2f}".format(line.base_price)}</span><span className="text-emerald-300">-{ "Rs. " + "{:.2f}".format(line.item_discount) } · {line.promo_note}</span></div></div> }}</div><div className="mt-3 flex flex-col gap-2 border-t border-dashed border-white/10 pt-3 text-sm"><div className="flex justify-between text-slate-400"><span>Shelf subtotal</span><span className="tabular-nums">Rs. {"{:.2f}".format(result.subtotal)}</span></div><div className="flex justify-between text-emerald-300"><span>Item discounts</span><span className="tabular-nums">- Rs. {"{:.2f}".format(result.item_discounts)}</span></div><div className="flex justify-between text-emerald-300"><span>Basket promotion</span><span className="tabular-nums">- Rs. {"{:.2f}".format(result.basket_discount)}</span></div><div className="mt-1 flex justify-between border-t border-white/5 pt-2 text-slate-300"><span>Delivery charges</span><span className="tabular-nums">Rs. {"{:.2f}".format(result.delivery_charge)}</span></div>{for delivery in result.deliveries { <div key={delivery.store} className="flex justify-between pl-3 text-xs text-slate-500"><span>{delivery.store} · {delivery.courier}</span><span className="tabular-nums">Rs. {"{:.2f}".format(delivery.charge)}</span></div> }}</div></div>
                                    <div className="rounded-xl border border-white/8 bg-white/[0.025] p-4"><div className="mb-4 flex items-center justify-between"><p className="text-sm font-semibold text-white">Requested delivery</p><Badge variant="outline" className="border-cyan-300/20 bg-cyan-300/5 text-cyan-200">{str(result.delivery_days)}d {str(result.delivery_hours)}h</Badge></div><p className="text-sm font-semibold text-white">{result.delivery_date}</p>{for delivery in result.deliveries { <p key={delivery.store} className="mt-1 text-sm text-slate-400">{delivery.store} · {delivery.courier}</p> }}</div>
                                    <p className="border-t border-dashed border-white/10 pt-3 text-xs text-slate-500">Estimated discounts and delivery charges use simulated local data. Mock card records only; no payment is processed.</p>
                                </div>
                            }}
                        </CardContent>
                    </Card>
                    <div className="rounded-2xl border border-cyan-300/10 bg-slate-900/55 p-4 shadow-lg shadow-black/10 backdrop-blur-xl transition-all duration-300 hover:border-cyan-300/25"><div className="flex items-start gap-3"><div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-cyan-300/10 text-cyan-200"><HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-4" /></div><div><p className="text-sm font-semibold text-slate-100">Fresh first, savings next</p><p className="mt-1 text-sm leading-relaxed text-slate-400">Perishables are flagged for prompt delivery. Pantry goods can wait for a promotion day. Stores, card promotions, and courier fees are all simulated locally.</p></div></div></div>
                </section>
            </div>
        </main>
    </div>;
}
