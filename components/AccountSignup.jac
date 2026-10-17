import from "@jac/runtime" { jacSignup, jacLogin, useNavigate, Link }
sv import from ..services.userProfile { saveDisplayName }
import from .ui.button { Button }
import from .ui.card { Card, CardContent, CardDescription, CardHeader, CardTitle }
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { ShoppingBag01Icon }


def:pub AccountSignup() -> JsxElement {
    has username: str = "";
    has email: str = "";
    has password: str = "";
    has busy: bool = False;
    has message: str = "";
    has success_message: str = "";
    nav = useNavigate();
    def handle_username(e: ChangeEvent) { username = e.target.value; }
    def handle_email(e: ChangeEvent) { email = e.target.value; }
    def handle_password(e: ChangeEvent) { password = e.target.value; }
    async def handle_submit -> None {
        busy = True;
        message = "";
        success_message = "";
        signup_result: dict | None = None;
        login_ok: bool = False;
        profile_message: str = "";
        if len(username.strip()) == 0 { message = "Choose a username for your account."; busy = False; return; }
        try {
            signup_result = await jacSignup(email, password, {"profile": {"firstname": username.strip()}});
            if not signup_result["success"] { message = str(signup_result["error"] or "Could not create account. Check your details."); }
            else {
                login_ok = await jacLogin(email, password);
                if login_ok {
                    profile_message = await saveDisplayName(username.strip());
                    if profile_message == "" { nav("/account/cards"); }
                    else { message = profile_message; }
                } else { success_message = "Account created. Please sign in to continue."; }
            }
        } except Exception { message = "Could not create the account. Use a valid email and a stronger password."; }
        busy = False;
    }
    return <div className="sb-app grid min-h-screen lg:grid-cols-2">
        <section className="relative hidden flex-col justify-between overflow-hidden border-r border-white/10 bg-slate-950/60 p-10 lg:flex">
            <Link to="/" className="flex items-center gap-3"><div className="flex size-10 items-center justify-center rounded-xl bg-emerald-300 text-slate-950"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div><span className="font-semibold text-white">Smart Basket</span></Link>
            <div className="max-w-lg"><p className="text-sm font-semibold uppercase tracking-[0.2em] text-emerald-300">Create your account</p><h1 className="mt-4 text-4xl font-semibold leading-tight text-white">Your basket, your cards, your choices.</h1><p className="mt-4 leading-relaxed text-slate-400">Save masked card references and use their issuer banks to discover eligible local promotions.</p></div>
            <p className="text-xs text-slate-500">No full card numbers or CVVs are stored. No payment is processed.</p>
        </section>
        <section className="flex items-center justify-center p-5 sm:p-8"><div className="w-full max-w-md">
            <div className="mb-8 flex items-center gap-3 lg:hidden"><div className="flex size-10 items-center justify-center rounded-xl bg-emerald-300 text-slate-950"><HugeiconsIcon icon={ShoppingBag01Icon} strokeWidth={2} className="size-5" /></div><span className="font-semibold text-white">Smart Basket</span></div>
            <div className="mb-6"><h2 className="text-2xl font-semibold text-white">Create account</h2><p className="mt-2 text-sm text-slate-400">Register your own standard user account. Admin accounts are provisioned separately by operators.</p></div>
            <Card className="sb-glass border-white/10 bg-slate-900/70 shadow-2xl"><CardHeader><CardTitle className="text-white">Account details</CardTitle><CardDescription className="text-slate-400">Choose a username, email, and unique password.</CardDescription></CardHeader><CardContent className="flex flex-col gap-4">
                <label className="flex flex-col gap-2 text-sm text-slate-200">Username<input value={username} onChange={handle_username} autoComplete="nickname" placeholder="How we should greet you" className="h-11 rounded-xl border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                <label className="flex flex-col gap-2 text-sm text-slate-200">Email<input type="email" value={email} onChange={handle_email} autoComplete="email" placeholder="you@example.com" className="h-11 rounded-xl border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                <label className="flex flex-col gap-2 text-sm text-slate-200">Password<input type="password" value={password} onChange={handle_password} autoComplete="new-password" className="h-11 rounded-xl border border-white/10 bg-slate-950/70 px-3 text-white outline-none focus:border-emerald-300/40" /></label>
                {if message != "" { <p role="alert" className="text-sm text-rose-200">{message}</p> }}
                {if success_message != "" { <p role="status" className="text-sm text-emerald-200">{success_message}</p> }}
                <Button disabled={busy} onClick={handle_submit} className="h-11 bg-emerald-300 font-semibold text-slate-950 hover:bg-emerald-200">{"Creating account..." if busy else "Create account"}</Button>
                <p className="text-center text-sm text-slate-400">Already registered? <Link to="/login" className="font-medium text-cyan-200 hover:text-white">Sign in</Link></p>
            </CardContent></Card>
        </div></section>
    </div>;
}
