sv import from ..services.basketService { InventoryRow, listStoreInventory }
import from "@jac/runtime" { Link }
import from .ui.button { Button }
import from .ui.card { Card, CardContent, CardDescription, CardHeader, CardTitle }
import from .ui.badge { Badge }
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { ShoppingBag01Icon }


def:pub StoreInventory() -> JsxElement {
    has rows: list[InventoryRow] = [];
    has store_name: str = "All stores";
    has loading: bool = True;
    has error_message: str = "";
    async can with entry {
        try { rows = await listStoreInventory(store_name); }
        except Exception { error_message = "Inventory could not be loaded. Please retry."; }
        loading = False;
    }
    def handle_store(e: ChangeEvent) { store_name = e.target.value; }
    async def handle_refresh -> None {
        loading = True;
        error_message = "";
        try { rows = await listStoreInventory(store_name); }
        except Exception { error_message = "Inventory could not be loaded. Please retry."; }
        loading = False;
    }
    return <div className="sb-app min-h-screen text-foreground">
        <header className="sticky top-0 z-20 border-b border-white/10 bg-slate-950/80 backdrop-blur-xl"><div className="mx-auto flex min-h-16 max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-2 sm:px-6"><Link to="/" className="flex items-center gap-3 text-white"><div className="flex size-9 items-center justify-center rounded-xl bg-emerald-300 text-slate-950"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-4" /></div><span className="font-semibold">Smart Basket</span></Link><Link to="/" className="text-sm text-cyan-200 hover:text-white">Back to basket</Link></div></header>
        <main className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-8 sm:px-6">
            <div><p className="text-xs font-semibold uppercase tracking-[0.18em] text-emerald-300">Browse stores</p><h1 className="mt-2 text-3xl font-semibold text-white">Store inventory</h1><p className="mt-2 text-sm text-slate-400">Browse all 25 supplied items, store prices, and active promotions.</p></div>
            <Card className="sb-glass border-white/10 bg-slate-900/70 shadow-xl"><CardHeader><CardTitle className="text-white">Compare catalog</CardTitle><CardDescription className="text-slate-400">Filter the catalog by store to inspect its current shelf and promotion price.</CardDescription></CardHeader><CardContent className="flex flex-col gap-5">
                <div className="flex flex-wrap items-end justify-between gap-3"><label className="flex min-w-56 flex-col gap-2 text-sm text-slate-200">Store<select value={store_name} onChange={handle_store} className="h-11 rounded-xl border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40"><option>All stores</option><option>Keells</option><option>Arpico</option><option>Cargills</option></select></label><Button onClick={handle_refresh} disabled={loading} className="bg-emerald-300 text-slate-950 hover:bg-emerald-200">{ "Loading inventory..." if loading else "Refresh inventory" }</Button></div>
                {if error_message != "" { <p role="alert" className="text-sm text-rose-200">{error_message}</p> }}
                {if loading { <p className="py-8 text-center text-sm text-slate-400">Loading store inventory...</p> }
                elif len(rows) == 0 { <div className="rounded-xl border border-dashed border-white/10 py-10 text-center"><p className="font-medium text-white">No inventory rows</p><p className="mt-1 text-sm text-slate-400">Choose another store or refresh.</p></div> }
                else {
                    <div className="flex flex-col gap-3 md:hidden">{for (index, row) in enumerate(rows) { <article key={str(index) + row.store + row.name} className="rounded-xl border border-white/10 bg-slate-950/45 p-4"><div className="flex items-start justify-between gap-3"><div><p className="font-medium text-slate-100">{row.name}</p><p className="mt-1 text-xs text-slate-400">{row.category} · {row.store}</p></div><div className="shrink-0 text-right"><p className="text-sm tabular-nums text-slate-300">Rs. {f"{row.price:.2f}"}</p><p className="text-xs tabular-nums text-emerald-200">{ f"Rs. {row.promo_price:.2f}" if row.promo_price > 0.0 else "No promo" }</p></div></div>{if row.promo_text != "" { <p className="mt-2 text-xs text-cyan-200">{row.promo_text}</p> }}</article> }}</div>
                    <div className="hidden overflow-x-auto rounded-xl border border-white/10 md:block"><table className="w-full min-w-[720px] text-left text-sm"><thead className="bg-white/[0.04] text-xs uppercase tracking-wider text-slate-400"><tr><th className="px-4 py-3">Item</th><th className="px-4 py-3">Category</th><th className="px-4 py-3">Store</th><th className="px-4 py-3 text-right">Shelf price</th><th className="px-4 py-3 text-right">Promo price</th><th className="px-4 py-3">Active offer</th></tr></thead><tbody>{for (index, row) in enumerate(rows) { <tr key={str(index) + row.store + row.name} className="border-t border-white/5 transition-colors hover:bg-white/[0.035]"><td className="px-4 py-3 font-medium text-slate-100">{row.name}</td><td className="px-4 py-3 text-slate-400">{row.category}</td><td className="px-4 py-3 text-slate-300">{row.store}</td><td className="px-4 py-3 text-right tabular-nums text-slate-300">{f"Rs. {row.price:.2f}"}</td><td className="px-4 py-3 text-right tabular-nums text-emerald-200">{ f"Rs. {row.promo_price:.2f}" if row.promo_price > 0.0 else "-" }</td><td className="px-4 py-3 text-xs text-slate-400">{row.promo_text if row.promo_text != "" else "-"}</td></tr> }}</tbody></table></div>
                }}
                <div className="flex flex-wrap gap-2"><Badge variant="outline" className="border-white/10 text-slate-400">25 supplied catalog products</Badge><Badge variant="outline" className="border-white/10 text-slate-400">Promotional prices shown separately</Badge></div>
            </CardContent></Card>
        </main>
    </div>;
}
