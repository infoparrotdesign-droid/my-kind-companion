-- Security hardening: this helper is not part of the public Parrot application API.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
