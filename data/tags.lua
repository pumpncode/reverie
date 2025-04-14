local function apply_stub(self, tag, context)
    if context.type == "new_blind_choice" then
        local lock = tag.ID
        G.CONTROLLER.locks[lock] = true

        tag:yep("+", G.C.SECONDARY_SET.Cine, function()
            local key = "p_dvrprv_film_normal_"..(math.random(1, 2))
            local card = Card(G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2, G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2,
                G.CARD_W * 1.27, G.CARD_H * 1.27, G.P_CARDS.empty, G.P_CENTERS[key], {
                    bypass_discovery_center = true,
                    bypass_discovery_ui = true
                })
            card.cost = 0
            card.from_tag = true

            G.FUNCS.use_card({
                config = {
                    ref_table = card
                }
            })
            card:start_materialize()
            G.CONTROLLER.locks[lock] = nil

            return true
        end)
        tag.triggered = true

        return true
    end
end

local function apply_stamp(self, tag, context)
    if context.type == "new_blind_choice" then
        local lock = tag.ID
        G.CONTROLLER.locks[lock] = true

        tag:yep("+", G.C.SECONDARY_SET.Tag, function()
            if tag.name == "Mega Stamp Tag" then
                local random_tag = Tag(get_next_tag_key("mega_stamp"))

                if random_tag.name == "Orbital Tag" then
                    local poker_hands = {}
                    for k, v in pairs(G.GAME.hands) do
                        if v.visible then
                            table.insert(poker_hands, k)
                        end
                    end

                    random_tag.ability.orbital_hand = pseudorandom_element(poker_hands, pseudoseed("mega_stamp_orbital"))
                end

                add_tag(random_tag)
            end

            local pack_key = "p_dvrprv_tag_jumbo_1"
            local card = Card(G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2, G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2,
                G.CARD_W * 1.27, G.CARD_H * 1.27, G.P_CARDS.empty, G.P_CENTERS[pack_key], {
                    bypass_discovery_center = true,
                    bypass_discovery_ui = true
                })
            card.cost = 0
            card.from_tag = true

            G.FUNCS.use_card({
                config = {
                    ref_table = card
                }
            })
            card:start_materialize()

            G.CONTROLLER.locks[lock] = nil

            return true
        end)
        tag.triggered = true

        return true
    end
end

Reverie.tags = {
    {
        key = "cine",
        order = 1,
        name = "Stub Tag",
        config = {
            type = "new_blind_choice"
        },
        pos = {
            x = 0,
            y = 0
        },
        loc_vars = function (self, info_queue)
            local fake_card = G.P_CENTERS.p_dvrprv_film_normal_1:create_fake_card()
            local info = G.P_CENTERS.p_dvrprv_film_normal_1:loc_vars(info_queue, fake_card)

            info_queue[#info_queue + 1] = {
                key = info.key,
                set = "Other",
                vars = info.vars
            }

            return {}
        end,
        apply = apply_stub
    },
    {
        key = "jumbo_tag",
        order = 2,
        name = "Stamp Tag",
        config = {
            type = "new_blind_choice"
        },
        pos = {
            x = 1,
            y = 0
        },
        yes_pool_flag = "tag_tag_available",
        loc_vars = function (self, info_queue)
            local fake_card = G.P_CENTERS.p_dvrprv_tag_jumbo_1:create_fake_card()
            local info = G.P_CENTERS.p_dvrprv_tag_jumbo_1:loc_vars(info_queue, fake_card)

            info_queue[#info_queue + 1] = {
                key = info.key,
                set = "Other",
                vars = info.vars
            }

            return {}
        end,
        apply = apply_stamp
    },
    {
        key = "mega_tag",
        order = 3,
        name = "Mega Stamp Tag",
        config = {
            type = "new_blind_choice"
        },
        pos = {
            x = 2,
            y = 0
        },
        yes_pool_flag = "tag_tag_available",
        loc_vars = function (self, info_queue)
            local fake_card = G.P_CENTERS.p_dvrprv_tag_jumbo_1:create_fake_card()
            local info = G.P_CENTERS.p_dvrprv_tag_jumbo_1:loc_vars(info_queue, fake_card)

            info_queue[#info_queue + 1] = {
                key = info.key,
                set = "Other",
                vars = info.vars
            }

            return {}
        end,
        apply = apply_stamp,
        dependencies = "CardSleeves"
    }
}

for _, v in pairs(Reverie.tags) do
    v.atlas = "cine_tags"

    SMODS.Tag(v)
end