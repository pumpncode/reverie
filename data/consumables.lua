Reverie.consumables = {
    {
        key = "reverie",
        set = "Spectral",
        atlas = "Cine",
        order = 1,
        name = "Reverie",
        pos = {
            x = 1,
            y = 1
        },
        cost = 4,
        hidden = true,
        soul_set = "Cine",
        can_use = function (self, card)
            return G.STATE == G.STATES.SHOP and G.shop
        end,
        use = Reverie.use_cine,
        set_sprites = function(self, card, front)
            card.ignore_base_shader = { ticket = true }
        end,
        draw = function(self, card, layer)
            if card.ARGS and card.ARGS.send_to_shader then
                if not (card.edition and card.edition.negative) then
                    card.ARGS.send_to_shader[3] = card.omit_top_half or 0
                    card.ARGS.send_to_shader[4] = card.omit_bottom_half or 0
        
                    card.children.center:draw_shader("dvrprv_ticket", nil, card.ARGS.send_to_shader)
                end
                if card.edition and card.edition.negative then
                    card.ARGS.send_to_shader[3] = card.omit_top_half or 0
                    card.ARGS.send_to_shader[4] = card.omit_bottom_half or 0
        
                    card.children.center:draw_shader("dvrprv_cine_negative", nil, card.ARGS.send_to_shader)
                end
            end
        end
    }
}

for _, v in pairs(Reverie.consumables) do
    SMODS.Consumable(v)
end