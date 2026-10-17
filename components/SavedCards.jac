sv import from ..services.paymentCards { SavedPaymentCard, listSavedCards, addSavedCard }
import from "@jac/runtime" { jacIsLoggedIn, jacLogout, useNavigate, Link }
import from .ui.button { Button }
import from .ui.card { Card, CardContent, CardDescription, CardHeader, CardTitle }
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { CreditCardIcon, ShoppingBag01Icon }


def:pub SavedCards() -> JsxElement {
    has saved_cards: list[SavedPaymentCard] = [];
    has nickname: str = "";
    has brand: str = "Visa";
    has last_four: str = "";
    has busy: bool = True;
    has error_message: str = "";
    has success_message: str = "";
    nav = useNavigate();
    async can with entry {
        if jacIsLoggedIn() {
            try { saved_cards = await listSavedCards(); }
            except Exception { error_message = "Could not load saved cards. Please retry."; }
        } else { nav("/login"); }
        busy = False;
    }
    def handle_nickname(e: ChangeEvent) { nickname = e.target.value; }
    def handle_brand(e: ChangeEvent) { brand = e.target.value; }
    def handle_last_four(e: ChangeEvent) { last_four = e.target.value; }
    async def handle_add -> None {
        error_message = "";
        success_message = "";
        if len(last_four) != 4 { error_message = "Enter exactly the last four digits."; return; }
        busy = True;
        try {
            card = await addSavedCard(nickname, brand, last_four);
            if card is None { error_message = "That card entry could not be saved. Check the nickname, brand, and last four digits."; }
            else { saved_cards = saved_cards + [card]; nickname = ""; last_four = ""; success_message = "Masked card saved to your account."; }
        } except Exception { error_message = "Could not save the card. Sign in and try again."; }
        busy = False;
    }
    def handle_logout(e: MouseEvent) { jacLogout(); nav("/login"); }

    return <div className="sb-app min-h-screen text-foreground">
        <header className="sticky top-0 z-20 border-b border-white/10 bg-slate-950/80 backdrop-blur-xl"><div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-4 sm:px-6"><Link to="/" className="flex items-center gap-3 text-white"><div className="flex size-9 items-center justify-center rounded-xl bg-emerald-300 text-slate-950"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-4" /></div><span className="font-semibold">Smart Basket</span></Link><div className="flex gap-3"><Link to="/" className="text-sm text-slate-300 hover:text-white">Basket</Link><button onClick={handle_logout} className="text-sm text-slate-400 hover:text-white">Sign out</button></div></div></header>
        <main className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-4 py-8 sm:px-6">
            <div><p className="text-xs font-semibold uppercase tracking-[0.18em] text-emerald-300">Account settings</p><h1 className="mt-2 text-3xl font-semibold text-white">Saved payment cards</h1><p className="mt-2 max-w-2xl text-sm leading-relaxed text-slate-400">Store a nickname, card brand, and last four digits for selection at checkout. Do not enter a full card number or security code. This demo does not process payments.</p></div>
            <div className="grid gap-5 lg:grid-cols-5">
                <Card className="sb-glass border-white/10 bg-slate-900/70 shadow-xl lg:col-span-3"><CardHeader><CardTitle className="text-white">Your cards</CardTitle><CardDescription className="text-slate-400">Only masked card references are kept in your account.</CardDescription></CardHeader><CardContent className="flex flex-col gap-3">
                    {if busy { <p className="py-8 text-center text-sm text-slate-400">Loading saved cards...</p> }
                    elif len(saved_cards) == 0 { <div className="rounded-xl border border-dashed border-white/10 bg-slate-950/40 px-4 py-10 text-center"><div className="mx-auto flex size-11 items-center justify-center rounded-xl bg-cyan-300/10 text-cyan-200"><HugeiconsIcon icon={CreditCardIcon} strokeWidth={2} className="size-5" /></div><p className="mt-3 font-medium text-white">No saved cards yet</p><p className="mt-1 text-sm text-slate-400">Add a masked card reference to use in the basket selector.</p></div> }
                    else { for card in saved_cards { <div key={card.brand + card.last_four + card.nickname} className="flex items-center gap-3 rounded-xl border border-white/10 bg-slate-950/40 p-4"><div className="flex size-10 items-center justify-center rounded-lg bg-cyan-300/10 text-cyan-200"><HugeiconsIcon icon={CreditCardIcon} strokeWidth={2} className="size-5" /></div><div className="min-w-0"><p className="font-medium text-white">{card.nickname}</p><p className="text-sm text-slate-400">{card.brand} ending in {card.last_four}</p></div><span className="ml-auto rounded-full border border-emerald-300/20 bg-emerald-300/5 px-2 py-1 text-[10px] uppercase tracking-wider text-emerald-200">Masked</span></div> } }}
                </CardContent></Card>
                <Card className="sb-glass border-white/10 bg-slate-900/70 shadow-xl lg:col-span-2"><CardHeader><CardTitle className="text-white">Add a card reference</CardTitle><CardDescription className="text-slate-400">Never enter a full card number or CVV here.</CardDescription></CardHeader><CardContent className="flex flex-col gap-4">
                    <label className="flex flex-col gap-2 text-sm text-slate-200">Nickname<input value={nickname} onChange={handle_nickname} maxLength={32} placeholder="Everyday card" className="h-10 rounded-lg border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                    <label className="flex flex-col gap-2 text-sm text-slate-200">Card brand<select value={brand} onChange={handle_brand} className="h-10 rounded-lg border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40"><option>Visa</option><option>Mastercard</option><option>American Express</option></select></label>
                    <label className="flex flex-col gap-2 text-sm text-slate-200">Last four digits<input inputMode="numeric" value={last_four} onChange={handle_last_four} maxLength={4} placeholder="1234" className="h-10 rounded-lg border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                    {if error_message != "" { <p role="alert" className="text-sm text-rose-200">{error_message}</p> }}
                    {if success_message != "" { <p role="status" className="text-sm text-emerald-200">{success_message}</p> }}
                    <Button onClick={handle_add} disabled={busy} className="bg-emerald-300 font-semibold text-slate-950 hover:bg-emerald-200">Save masked card</Button>
                </CardContent></Card>
            </div>
        </main>
    </div>;
}
