node SavedPaymentCard {
    has nickname: str;
    has brand: str;
    has last_four: str;
}

def:protect listSavedCards() -> list[SavedPaymentCard] {
    return [root -->][?:SavedPaymentCard];
}

def:protect addSavedCard(nickname: str, brand: str, last_four: str) -> SavedPaymentCard | None {
    clean_nickname = nickname.strip();
    clean_brand = brand.strip();
    clean_last_four = last_four.strip();
    if len(clean_nickname) == 0 or len(clean_nickname) > 32 { return None; }
    if clean_brand not in ["Visa", "Mastercard", "American Express"] { return None; }
    if len(clean_last_four) != 4 { return None; }
    for digit in clean_last_four {
        if digit not in "0123456789" { return None; }
    }
    return root ++> SavedPaymentCard(nickname=clean_nickname, brand=clean_brand, last_four=clean_last_four);
}
