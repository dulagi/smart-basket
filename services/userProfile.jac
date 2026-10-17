node BasketProfile {
    has display_name: str;
}

def:protect saveDisplayName(display_name: str) -> str {
    clean_name = display_name.strip();
    if len(clean_name) == 0 or len(clean_name) > 40 { return "Choose a username between 1 and 40 characters."; }
    profiles = [root -->][?:BasketProfile];
    if len(profiles) > 0 {
        profiles[0].display_name = clean_name;
    } else {
        root ++> BasketProfile(display_name=clean_name);
    }
    return clean_name;
}

def:protect getDisplayName() -> str {
    profiles = [root -->][?:BasketProfile];
    if len(profiles) > 0 { return profiles[0].display_name; }
    return "";
}
