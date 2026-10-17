import from "@jac/runtime" { jacLogin, useNavigate, Link }
import from .ui.button { Button }
import from .ui.card { Card, CardContent, CardDescription, CardHeader, CardTitle }
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { ShoppingBag01Icon }


def:pub AccountLogin() -> JsxElement {
    has email: str = "";
    has password: str = "";
    has busy: bool = False;
    has message: str = "";
    nav = useNavigate();
    def handle_email(e: ChangeEvent) { email = e.target.value; }
    def handle_password(e: ChangeEvent) { password = e.target.value; }
    async def handle_submit -> None {
        busy = True;
        message = "";
        ok: bool = False;
        try {
            ok = await jacLogin(email, password);
            if ok { nav("/account/cards"); }
            else { message = "Sign-in failed. Check your account details."; }
        } except Exception {
            message = "We could not sign in. Check your connection and try again.";
        }
        busy = False;
    }
    return <div className="sb-app grid min-h-screen lg:grid-cols-2">
        <section className="relative hidden flex-col justify-between overflow-hidden border-r border-white/10 bg-slate-950/60 p-10 lg:flex">
            <Link to="/" className="flex items-center gap-3"><div className="flex size-10 items-center justify-center rounded-xl bg-emerald-300 text-slate-950"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div><span className="font-semibold text-white">Smart Basket</span></Link>
            <div className="max-w-lg"><p className="text-sm font-semibold uppercase tracking-[0.2em] text-emerald-300">Your account</p><h1 className="mt-4 text-4xl font-semibold leading-tight text-white">Keep your checkout preferences close.</h1><p className="mt-4 leading-relaxed text-slate-400">Saved payment methods are stored as a nickname, card brand, and last four digits only. No full card number or CVV is collected.</p></div>
            <p className="text-xs text-slate-500">Mock checkout experience. No payments are processed.</p>
        </section>
        <section className="flex items-center justify-center p-5 sm:p-8"><div className="w-full max-w-md">
            <div className="mb-8 flex items-center gap-3 lg:hidden"><div className="flex size-10 items-center justify-center rounded-xl bg-emerald-300 text-slate-950"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div><span className="font-semibold text-white">Smart Basket</span></div>
            <div className="mb-6"><h2 className="text-2xl font-semibold text-white">Sign in</h2><p className="mt-2 text-sm text-slate-400">Sign in to manage your masked saved cards.</p></div>
            <Card className="sb-glass border-white/10 bg-slate-900/70 shadow-2xl"><CardHeader><CardTitle className="text-white">Account access</CardTitle><CardDescription className="text-slate-400">Use your Smart Basket account credentials.</CardDescription></CardHeader><CardContent className="flex flex-col gap-4">
                <label className="flex flex-col gap-2 text-sm text-slate-200">Email<input type="email" value={email} onChange={handle_email} autoComplete="email" placeholder="you@example.com" className="h-11 rounded-xl border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                <label className="flex flex-col gap-2 text-sm text-slate-200">Password<input type="password" value={password} onChange={handle_password} autoComplete="current-password" className="h-11 rounded-xl border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                {if message != "" { <p role="alert" className="text-sm text-rose-200">{message}</p> }}
                <Button disabled={busy} onClick={handle_submit} className="h-11 bg-emerald-300 font-semibold text-slate-950 hover:bg-emerald-200">{"Signing in..." if busy else "Sign in"}</Button>
                <p className="text-center text-sm text-slate-400">New to Smart Basket? <Link to="/signup" className="font-medium text-cyan-200 hover:text-white">Create account</Link></p>
            </CardContent></Card>
        </div></section>
    </div>;
}
