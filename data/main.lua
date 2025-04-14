Reverie = SMODS.current_mod
Reverie.prefix = "dvrprv"
Reverie.badge_colour = HEX("9db95f")
Reverie.flipped_voucher_pos = {
    x = 1,
    y = 0
}
Reverie.flipped_tag_pos = {
    x = 0,
    y = 1
}
Reverie.flipped_booster_pos = {
    x = 5,
    y = 0
}

function G.FUNCS.reverie_unlock_all()
    local keys = {
        "b_dvrprv_filmstrip",
        "b_dvrprv_stamp",
        "v_dvrprv_megaphone",
    }

    for _, key in ipairs(keys) do
        local card = G.P_CENTERS[key]
        unlock_card(card)
    end
end

SMODS.current_mod.config_tab = function()
    local jokerDisplay = Reverie.find_mod("JokerDisplay")
    local cartomancer = Reverie.find_mod("cartomancer")

    return {
        n = G.UIT.ROOT,
        config = {
            align = "tm",
            r = 0.1,
            padding = 0.2,
            colour = G.C.BLACK
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm"
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_dvrprv_title") .. " v" .. Reverie.version,
                            scale = 0.7,
                            colour = Reverie.badge_colour
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = {
                    align = "cm"
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_dvrprv_description"),
                            scale = 0.4,
                            colour = G.C.UI.TEXT_INACTIVE
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = {
                    minh = 0.1
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    {
                        n = G.UIT.O,
                        config = {
                            object = DynaText({
                                string = { "......................................" },
                                colours = { G.C.WHITE },
                                shadow = true,
                                float = true,
                                y_offset = -30,
                                scale = 0.45,
                                spacing = 13.5,
                                font = G.LANGUAGES["en-us"].font,
                                pop_in = 0
                            })
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = {
                    align = "cm"
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            minw = 3
                        },
                        nodes = {
                            UIBox_button({
                                label = { "Unlock Reverie Cards" },
                                button = 'reverie_unlock_all'
                            }),
                            create_toggle({
                                label = localize("b_dvrprv_tag_packs_shop"),
                                info = localize("b_dvrprv_tag_packs_shop_info"),
                                active_colour = Reverie.badge_colour,
                                ref_table = Reverie.config,
                                ref_value = "tag_packs_shop"
                            }),
                            create_toggle({
                                label = localize("b_dvrprv_crazy_packs_shop"),
                                info = localize("b_dvrprv_crazy_packs_shop_info"),
                                active_colour = Reverie.badge_colour,
                                ref_table = Reverie.config,
                                ref_value = "crazy_packs_shop"
                            }),
                            create_toggle({
                                label = localize("b_dvrprv_custom_morsel_compat"),
                                info = localize("b_dvrprv_custom_morsel_compat_info"),
                                active_colour = Reverie.badge_colour,
                                ref_table = Reverie.config,
                                ref_value = "custom_morsel_compat"
                            })
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            minh = 0.1
                        }
                    },
                    {
                        n = G.UIT.C,
                        nodes = {
                            jokerDisplay and create_toggle({
                                label = localize("b_dvrprv_jokerdisplay_compat"),
                                info = localize("b_dvrprv_jokerdisplay_compat_info"),
                                active_colour = Reverie.badge_colour,
                                ref_table = Reverie.config,
                                ref_value = "jokerdisplay_compat"
                            }) or nil,
                            cartomancer and create_toggle({
                                label = localize("b_dvrprv_cartomancer_compat"),
                                info = localize("b_dvrprv_cartomancer_compat_info"),
                                active_colour = Reverie.badge_colour,
                                ref_table = Reverie.config,
                                ref_value = "cartomancer_compat"
                            }) or nil
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = {
                    minh = 0.1
                }
            }
        }
    }
end

function G.FUNCS.handle_reverie_cartomancer_cycle(args)
    Reverie.config.cartomancer_compat_show_after = args.to_val
end

local get_starting_params_ref = get_starting_params
function get_starting_params()
    local params = get_starting_params_ref()

    params.cine_quest_slots = 1

    return params
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    start_run_ref(self, args)

    -- Allowing modded consumables to be appear in Crazy Lucky Pack
    -- Temporal solution though
    for _, v in pairs(G.P_CENTERS) do
        if v.consumeable and not get_index(G.P_CENTER_POOLS.Consumeables, v) then
            table.insert(G.P_CENTER_POOLS.Consumeables, v)
        end
    end

    Reverie.set_cine_banned_keys()
    set_screen_positions()

    G.GAME.selected_back:trigger_effect({
        context = "setting_tags"
    })

    if G.GAME.selected_sleeve then
        CardSleeves.Sleeve:get_obj(G.GAME.selected_sleeve or "sleeve_casl_none"):trigger_effect({
            context = "setting_tags"
        })
    end
end

local set_screen_positions_ref = set_screen_positions
function set_screen_positions()
    set_screen_positions_ref()

    if G.STAGE == G.STAGES.RUN and G.cine_quests then
        G.cine_quests.T.x = G.TILE_W - G.cine_quests.T.w - 0.3
        G.cine_quests.T.y = 3
        G.cine_quests:hard_set_VT()
    end
end

function Reverie.end_cine_shop()
    if G.GAME.cached_oddity_rate then
        G.GAME.oddity_rate = G.GAME.cached_oddity_rate
    end

    if G.GAME.cached_alchemical_rate then
        G.GAME.alchemical_rate = G.GAME.cached_alchemical_rate
    end

    if G.GAME.current_round.cine_temporary_consumeable_limit then
        G.GAME.current_round.cine_temporary_consumeable_limit = nil
        G.consumeables.config.card_limit = G.consumeables.config.card_limit -
            G.P_CENTERS.c_dvrprv_alchemist.config.extra.slot
    end

    if G.GAME.current_round.cine_temporary_shop_card_limit then
        G.GAME.current_round.cine_temporary_shop_card_limit = nil
        G.GAME.shop.joker_max = G.GAME.shop.joker_max - G.P_CENTERS.v_dvrprv_script.config.extra
        G.shop_jokers.config.card_limit = G.GAME.shop.joker_max
    end

    G.GAME.current_round.max_boosters = nil
    G.GAME.current_round.used_cine = nil
    Reverie.set_cine_banned_keys()
end

function Reverie.create_tag_as_card(area, big)
    local _pool, _pool_key = get_current_pool("Tag")

    --cull the pool manually, because Vanilla doesn't do it for tags normally (as it should)
    for k, v in ipairs(_pool) do
        if v ~= "UNAVAILABLE" and G.GAME.used_jokers[v] then
            _pool[k] = "UNAVAILABLE"
        end
    end

    local key = pseudorandom_element(_pool, pseudoseed(_pool_key))
    local it = 1

    while key == "UNAVAILABLE" do
        it = it + 1
        key = pseudorandom_element(_pool, pseudoseed(_pool_key .. "_resample" .. it))
        if it > 100 then
            key = "tag_handy" -- default tag when all tags are used
        end
    end

    local center = G.P_TAGS[key]
    center.atlas = center.atlas or "tags"
    local size = big and 1.2 or 0.8

    local card = Card(area.T.x + area.T.w / 2, area.T.y, size, size, nil, center, {
        bypass_discovery_center = area == G.shop_jokers,
        bypass_discovery_ui = area == G.shop_jokers,
        discover = false,
        bypass_back = G.GAME.selected_back.pos
    })
    card.config.center_key = key
    card.ability.tag = Tag(key, false, "Small")
    card.ability.tag.ability.as_card = true

    -- card.ability.tag:set_ability()

    for k, v in pairs(card.ability.tag.ability) do
        card.ability[k] = v
    end

    card.base_cost = G.P_CENTERS.c_dvrprv_tag_or_die.config.extra.cost
    card:set_cost()

    -- Prevents orbital tag from always being the same hand
    if card.ability.name == "Orbital Tag" then
        local poker_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if v.visible then
                table.insert(poker_hands, k)
            end
        end

        card.ability.orbital_hand = pseudorandom_element(poker_hands, pseudoseed("orbital"))
        card.ability.tag.ability.orbital_hand = card.ability.orbital_hand
    end

    -- Ortalab compat to prevent Constellation patch from always being the same hand
    if Reverie.find_mod("ortalab") and card.ability.name == "tag_ortalab_constellation" then
        local _poker_hands = {}
        for k, _ in pairs(G.ZODIACS) do
            _poker_hands[#_poker_hands+1] = k
        end

        local zodiac1 = pseudorandom_element(_poker_hands, pseudoseed('constellation_patch'))
        local zodiac2 = pseudorandom_element(_poker_hands, pseudoseed('constellation_patch'))
        while zodiac1 == zodiac2 do
            zodiac2 = pseudorandom_element(_poker_hands, pseudoseed('constellation_patch'))
        end

        card.ability.zodiac_hands = {zodiac1, zodiac2}
        card.ability.tag.ability.zodiac_hands = card.ability.zodiac_hands
    end

    return card
end

function Reverie.create_booster(area, center)
    local card = Card(area.T.x + area.T.w / 2, area.T.y, G.CARD_W * 1.27, G.CARD_H * 1.27, G.P_CARDS.empty, center, {
        bypass_discovery_center = true,
        bypass_discovery_ui = true
    })
    create_shop_card_ui(card, "Booster", area)

    return card
end

function Reverie.create_crazy_random_card(area)
    local cumulative, pointer, target, card = 0, 0, nil, nil
    local tag_or_die = Reverie.find_used_cine("Tag or Die")
    local weights = {}

    for k, v in pairs(G.P_CENTERS.p_dvrprv_crazy_lucky_1.config.weights) do
        weights[k] = v * (k == "Tag" and tag_or_die and 3 or 1)
    end

    for _, v in pairs(weights) do
        cumulative = cumulative + v
    end

    local poll = pseudorandom(pseudoseed("crazy_pack" .. G.GAME.round_resets.ante)) * cumulative

    for k, v in pairs(weights) do
        pointer = pointer + v

        if pointer >= poll and pointer - v <= poll then
            target = k
            break
        end
    end

    if target == "Joker" then
        card = Reverie.create_special_joker(G.pack_cards)

        if not card then
            card = create_card(target, area, nil, nil, true, true, nil, "crazy_j")
        end
    elseif target == "Consumeables" then
        local consumable_types = {}

        if Reverie.find_used_cine("Let It Moon") then
            table.insert(consumable_types, "Tarot_Planet")
        end
        if Reverie.find_used_cine("Eerie Inn") then
            table.insert(consumable_types, "Spectral")
        end
        if Reverie.find_used_cine("Fool Metal Alchemist") then
            table.insert(consumable_types, "Alchemical")
        end
        if Reverie.find_used_cine("Every Hue") then
            table.insert(consumable_types, "Colour")
        end

        if #consumable_types > 0 then
            local type = pseudorandom_element(consumable_types, pseudoseed("cine_consumable"))
            card = create_card(type, area, nil, nil, true, true, nil, "crazy_consumable")
        else
            local pool, pool_key = get_current_pool(target, nil, nil, "crazy_c")
            local center = pseudorandom_element(pool, pseudoseed(pool_key))
            local it = 1

            while center == "UNAVAILABLE" or (G.P_CENTERS[center].set == "Cine" and not G.P_CENTERS[center].reward) do
                it = it + 1
                center = pseudorandom_element(pool, pseudoseed(pool_key .. "_resample" .. it))
            end

            card = create_card(target, area, nil, nil, true, true, center, "crazy_c")
        end
    elseif target == "Voucher" then
        card = create_card(target, area, nil, nil, true, true, nil, "crazy_v")
    elseif target == "Cine" then
        card = create_card(target, area, nil, nil, true, true, nil, "crazy_cine")
    elseif target == "Playing" then
        if Reverie.find_used_cine("Poker Face") then
            card = Reverie.create_poker_face_card(G.pack_cards)
        else
            card = create_card(
                (pseudorandom(pseudoseed("crazy_playing" .. G.GAME.round_resets.ante)) > 0.6) and "Enhanced" or "Base",
                G.pack_cards, nil, nil, nil, true, nil, "crazy_p")
            local edition_rate = 2
            local edition = poll_edition("crazy_edition" .. G.GAME.round_resets.ante, edition_rate, true)
            card:set_edition(edition)

            local seal_rate = 10
            local seal_poll = pseudorandom(pseudoseed("crazy_seal" .. G.GAME.round_resets.ante))

            if seal_poll > 1 - 0.02 * seal_rate then
                local seal_type = pseudorandom(pseudoseed("crazy_sealtype" .. G.GAME.round_resets.ante))

                if seal_type > 0.75 then
                    card:set_seal("Red")
                elseif seal_type > 0.5 then
                    card:set_seal("Blue")
                elseif seal_type > 0.25 then
                    card:set_seal("Gold")
                else
                    card:set_seal("Purple")
                end
            end
        end
    elseif target == "Tag" then
        card = Reverie.create_tag_as_card(area, true)
    end

    if not card then
        card = create_card("Joker", area, nil, nil, true, true, nil, "crazy_j")
    end

    return card
end

function Reverie.create_special_joker(area)
    local card = nil
    local cine_joker_types = {}

    if Reverie.find_used_cine("Morsel") then
        table.insert(cine_joker_types, "Morsel")
    end
    if Reverie.find_used_cine("I Sing, I've No Shape") and G.jokers.cards and G.jokers.cards[1] then
        table.insert(cine_joker_types, "I Sing, I've No Shape")
    end
    if Reverie.find_used_cine("Radioactive") then
        table.insert(cine_joker_types, "Radioactive")
    end
    if Reverie.find_used_cine("Jovial M") then
        table.insert(cine_joker_types, "Jovial M")
    end

    if #cine_joker_types > 0 then
        local type = pseudorandom_element(cine_joker_types, pseudoseed("cine_joker"))

        if type == "Morsel" then
            local available = Reverie.get_food_jokers()

            for i, key in ipairs(available) do
                if (G.GAME.used_jokers[key] and not next(find_joker("Showman"))) then
                    available[i] = nil
                end
            end

            if next(available) == nil then
                table.insert(available, "j_ice_cream")
            end

            local target = pseudorandom_element(available, pseudoseed("mor"))
            card = { set = "Joker", area = area, key = target, key_append = "sel" }
            -- card = create_card("Joker", area, nil, nil, nil, nil, target, "sel")
        elseif type == "I Sing, I've No Shape" then
            local force = pseudorandom_element(G.jokers.cards, pseudoseed("ising"))
            card = { set = "Joker", area = area, key = force.config.center.key, key_append = "iveno" }
            -- card = create_card("Joker", area, nil, nil, nil, nil, force.config.center.key, "iveno")
        elseif type == "Radioactive" then
            local available = Reverie.get_fusion_materials()
            local fallback = pseudorandom_element(available, pseudoseed("radio_fallback"))

            if not next(find_joker("Showman")) then
                for i, v in ipairs(available) do
                    if next(find_joker(G.P_CENTERS[v].name)) then
                        available[i] = nil
                    end
                end
            end

            if next(available) == nil then
                table.insert(available, fallback)
            end

            local target = pseudorandom_element(available, pseudoseed("radio"))
            card = { set = "Joker", area = area, key = target, key_append = "active" }
            -- card = create_card("Joker", area, nil, nil, nil, nil, target, "active")
        elseif type == "Jovial M" then
            local rarity = pseudorandom_element({
                "cry_epic",
                "cry_exotic"
            }, pseudoseed("jovial_rarity"))
            card = { set = "Joker", area = area, rarity = rarity, key_append = "jovial" }
            -- card = create_card("Joker", area, nil, pseudorandom_element({
            --     "cry_epic",
            --     "cry_exotic"
            -- }, pseudoseed("jovial_rarity")), nil, nil, nil, "jovial")
        end
    end

    if card then
        card = SMODS.create_card(card)
    end
    return card
end

function Reverie.create_poker_face_card(area)
    local target = pseudorandom_element(G.deck.cards, pseudoseed("pokerface"))
    local c = Card(area.T.x + area.T.w / 2, area.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS.c_base)

    return copy_card(target, c)
end

function Reverie.get_food_jokers()
    local result = {}
    local foods = {
        G.GAME.pool_flags.gros_michel_extinct and "j_cavendish" or "j_gros_michel",
        "j_ice_cream",
        "j_turtle_bean",
        "j_diet_cola",
        "j_popcorn",
        "j_ramen",
        "j_selzer",
        "j_egg",
        "j_mf_lollipop",
        "j_mf_goldencarrot",
        "j_mf_tonersoup",
        "j_mf_teacup",
        "j_cafeg",
        "j_cherry",
        G.GAME.pool_flags.taliaferro_extinct and "j_ortalab_royal_gala" or "j_ortalab_taliaferro",
        "j_ortalab_fine_wine",
        "j_ortalab_mystery_soda",
        "j_ortalab_popcorn_bag",
        "j_cry_pickle",
        "j_cry_chili_pepper",
        "j_cry_oldcandy",
        "j_cry_caramel",
        "j_cry_foodm",
        "j_cry_crustulum",
        "j_evo_full_sugar_cola",
        "j_kcva_fortunecookie",
        "j_kcva_swiss",
        "j_sdm_burger",
        "j_sdm_pizza",
        "j_snow_turkey_dinner",
        "j_ssj_coffee",
        "j_jank_cut_the_cheese",
        G.GAME.pool_flags.soft_taco_can_spawn and "j_paperback_soft_taco" or "j_paperback_crispy_taco",
        "j_paperback_nachos",
        "j_paperback_complete_breakfast",
        "j_paperback_ghost_cola",
        "j_paperback_joker_cookie",
        "j_paperback_cakepop",
        "j_paperback_caramel_apple",
        "j_paperback_charred_marshmallow",
        "j_paperback_dreamsicle",
        "j_paperback_apple",
        "j_paperback_coffee",
        "j_paperback_cream_liqueur",
        "j_paperback_epic_sauce",
        "j_paperback_champagne",
        "j_twewy_candleService",
        "j_twewy_burningCherry",
        "j_twewy_burningMelon",
        "j_cosmos_milkandcookies",
        "j_kcvanilla_fortunecookie",
        "j_neat_frostedprimerib",
        G.GAME.pool_flags.gfondue_licked and "j_buf_camarosa" or "j_buf_gfondue"
    }

    -- Bunco exotic suit jokers
    if G.GAME and G.GAME.Exotic then
        table.insert(foods, "j_bunc_starfruit")
        table.insert(foods, "j_bunc_fondue")
    end

    for _, v in pairs(foods) do
        if G.P_CENTERS[v] then
            result[#result + 1] = v
        end
    end

    return result
end

function Reverie.is_food_joker(key)
    for _, v in ipairs(Reverie.get_food_jokers()) do
        if v == key then
            return true
        end
    end
end

function Reverie.double_ability(origin, new)
    for k, v in pairs(origin) do
        if type(v) == "number" then
            new[k] = v * 2

            if k == "Xmult" then
                new.x_mult = v * 2
            end
        elseif type(v) == "table" then
            Reverie.double_ability(v, new[k])
        end
    end
end

function Reverie.morselize_UI(card)
    local alternative = G.localization.descriptions.Joker[card.config.center_key .. "_morsel_alternative"]
    if alternative and (Reverie.config.custom_morsel_compat or card.config.center.key == "j_diet_cola") then
        local temp_main = {}
        local loc_vars = {}

        if card.config.center.key == "j_olab_fine_wine" then
            loc_vars = { card.ability.extra.discards }
        elseif card.config.center.key == "j_mf_goldencarrot" then
            loc_vars = { nil, 2 }
        elseif card.config.center.key == "j_pape_ghost_cola" then
            loc_vars = { localize {
                type = "name_text",
                set = "Tag",
                key = "tag_negative"
            } }
        elseif card.config.center.key == "j_diet_cola" then
            loc_vars = { localize {
                type = "name_text",
                set = "Tag",
                key = "tag_double"
            } }
        end

        localize {
            type = "descriptions",
            key = card.config.center_key .. "_morsel_alternative",
            set = card.ability.set,
            nodes = temp_main,
            vars = loc_vars
        }

        for i, v in ipairs(alternative.text) do
            if v ~= "." then
                card.ability_UIBox_table.main[i] = temp_main[i]
            end
        end
    end

    table.insert(card.ability_UIBox_table.badges, "morseled")
    table.insert(card.ability_UIBox_table.info, {})
    local last_info = card.ability_UIBox_table.info[#card.ability_UIBox_table.info]
    localize {
        type = "other",
        key = "morseled",
        nodes = last_info
    }
    last_info.name = localize {
        type = 'name_text',
        key = "morseled",
        set = "Other"
    }
end

function Reverie.get_fusion_materials()
    local materials = {}

    for _, v in ipairs(FusionJokers.fusions) do
        for _, vv in ipairs(v.jokers) do
            if G.P_CENTERS[vv.name] then
                table.insert(materials, vv.name)
            end
        end
    end

    return materials
end

function Reverie.is_cine_or_reverie(card)
    return card.ability.set == "Cine" or (card.ability.set == "Spectral" and card.ability.name == "Reverie")
end

function Reverie.find_used_cine(name)
    return G.GAME.current_round.used_cine and get_index(G.GAME.current_round.used_cine, name) or nil
end

function Reverie.find_used_cine_or(...)
    if not G.GAME.current_round.used_cine then
        return false
    end

    local names = { ... }

    for _, v in ipairs(names) do
        if get_index(G.GAME.current_round.used_cine, v) then
            return true
        end
    end

    return false
end

function Reverie.find_used_cine_all(...)
    if not G.GAME.current_round.used_cine then
        return false
    end

    local names = { ... }

    for _, v in ipairs(names) do
        if not get_index(G.GAME.current_round.used_cine, v) then
            return false
        end
    end

    return true
end

function Reverie.is_cine_forcing_card_set()
    return Reverie.find_used_cine_or("I Sing, I've No Shape", "Crazy Lucky", "Tag or Die", "Let It Moon",
        "Poker Face", "Eerie Inn", "Morsel", "Gem Heist", "Fool Metal Alchemist", "Every Hue", "Radioactive", "Jovial M")
end

function Reverie.get_used_cine_kinds()
    if not G.GAME.current_round.used_cine then
        return nil
    elseif Reverie.find_used_cine("Crazy Lucky") then
        return {
            "p_dvrprv_crazy_lucky"
        }
    end

    local flag, kinds = {}, {}

    for _, v in ipairs(G.GAME.current_round.used_cine) do
        local center = Reverie.find_cine_center(v)

        if type(center.config.extra) == "table" and center.config.extra.kind and not flag[v] then
            for _, k in ipairs(center.config.extra.kind) do
                table.insert(kinds, k)
            end

            flag[v] = true
        end
    end

    if #kinds == 0 then
        kinds = nil
    end

    return kinds
end

function Reverie.find_cine_center(name)
    for _, v in pairs(G.P_CENTERS) do
        if v.set == "Cine" and v.name == name then
            return v
        end
    end

    return nil
end

local create_card_shop_ref = create_card_for_shop
function create_card_for_shop(area)
    if G.GAME.current_round.used_cine then
        return Reverie.create_card_for_cine_shop(area)
    else
        return create_card_shop_ref(area)
    end
end

function Reverie.create_card_for_cine_shop(area)
    local kinds, kind = Reverie.get_used_cine_kinds(), nil

    if G.GAME.starting_params.ksrgacha and (Reverie.find_used_cine("Adrifting") or kinds) then
        if kinds then
            kind = pseudorandom_element(kinds, pseudoseed("cine_booster"))
        end

        local center = kind and Reverie.get_pack_by_slug("shop_pack", kind).key or get_pack("shop_pack").key
        local card = Card(area.T.x + area.T.w / 2, area.T.y,
            G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[center], {
                bypass_discovery_center = true,
                bypass_discovery_ui = true
            })
        create_shop_card_ui(card, "Booster", area)

        return card
    end

    local forced_tag = nil
    local is_forcing_card_set = Reverie.is_cine_forcing_card_set()

    Reverie.ban_modded_consumables()

    for _, v in ipairs(G.GAME.tags) do
        if not forced_tag and not is_forcing_card_set then
            forced_tag = v:apply_to_run({
                type = "store_joker_create",
                area = area
            })

            if forced_tag and Reverie.find_used_cine("Adrifting") and #G.GAME.current_round.used_cine == 1 then
                for _, vv in ipairs(G.GAME.tags) do
                    if vv:apply_to_run({
                            type = "store_joker_modify",
                            card = forced_tag
                        }) then
                        break
                    end
                end

                return forced_tag
            end
        end
    end

    local has_oddity = Reverie.find_mod("TheAutumnCircus") and OddityAPI
    local has_alchemical = Reverie.find_mod("CodexArcanum")
    local has_colour = Reverie.find_mod("MoreFluff")

    local crazy_pack_available = Reverie.find_used_cine("Crazy Lucky")
    local joker_available = (Reverie.find_used_cine_or("I Sing, I've No Shape", "Morsel", "Gem Heist", "Radioactive", "Jovial M") or (not Reverie.find_mod("Bunco") and Reverie.find_used_cine("Gem Heist")) or not is_forcing_card_set) and
        not crazy_pack_available
    local planet_or_tarot_available = (Reverie.find_used_cine("Let It Moon") or not is_forcing_card_set) and
        not crazy_pack_available
    local playing_available = (Reverie.find_used_cine("Poker Face") or (not Reverie.find_mod("Bunco") and Reverie.find_used_cine("Gem Heist")) or not is_forcing_card_set) and
        not crazy_pack_available
    local spectral_available = (Reverie.find_used_cine("Eerie Inn") or not is_forcing_card_set) and
        not crazy_pack_available
    local tag_available = Reverie.find_used_cine("Tag or Die") and not crazy_pack_available
    local oddity_available, alchemical_available, colour_available = nil, nil, nil

    local playing_card_rate = Reverie.find_used_cine("Poker Face") and G.GAME.joker_rate or G.GAME.playing_card_rate or 0
    local spectral_rate = Reverie.find_used_cine("Eerie Inn") and G.GAME.joker_rate or G.GAME.spectral_rate or 0
    local oddity_rate, alchemical_rate, colour_rate = nil, nil, nil
    local total_rate = (joker_available and G.GAME.joker_rate or 0)
        + (planet_or_tarot_available and (G.GAME.tarot_rate + G.GAME.planet_rate) or 0)
        + (playing_available and playing_card_rate or 0)
        + (spectral_available and spectral_rate or 0)
        + (tag_available and G.GAME.joker_rate or 0)
        + (crazy_pack_available and G.GAME.joker_rate or 0)
    local candidates = {
        { type = "Joker",  val = joker_available and G.GAME.joker_rate or 0,            available = joker_available },
        { type = "Tarot",  val = planet_or_tarot_available and G.GAME.tarot_rate or 0,  available = planet_or_tarot_available },
        { type = "Planet", val = planet_or_tarot_available and G.GAME.planet_rate or 0, available = planet_or_tarot_available },
        {
            type = (G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed("illusion")) > 0.6) and "Enhanced" or
                "Base",
            val = playing_available and playing_card_rate or 0,
            available = playing_available
        },
        { type = "Spectral", val = spectral_available and spectral_rate or 0,       available = spectral_available },
        { type = "Tag",      val = tag_available and G.GAME.joker_rate or 0,        available = tag_available },
        { type = "Crazy",    val = crazy_pack_available and G.GAME.joker_rate or 0, available = crazy_pack_available },
    }

    if has_oddity then
        oddity_rate = (G.GAME.oddity_rate or 0) > 0 and G.GAME.oddity_rate or G.GAME.cached_oddity_rate or 0
        oddity_available = not is_forcing_card_set and not crazy_pack_available
        total_rate = total_rate + (oddity_available and oddity_rate or 0)
        table.insert(candidates,
            { type = "Oddity", val = oddity_available and oddity_rate or 0, available = oddity_available })
    end

    if has_alchemical then
        alchemical_rate = Reverie.find_used_cine_or("Fool Metal Alchemist") and G.GAME.joker_rate or
            G.GAME.alchemical_rate or G.GAME.cached_alchemical_rate or 0
        alchemical_available = (Reverie.find_used_cine_or("Fool Metal Alchemist") or not is_forcing_card_set) and
            not crazy_pack_available
        total_rate = total_rate + (alchemical_available and alchemical_rate or 0)
        table.insert(candidates,
            { type = "Alchemical", val = alchemical_available and alchemical_rate or 0, available = alchemical_available })
    end

    if has_colour then
        colour_rate = Reverie.find_used_cine("Every Hue") and G.GAME.joker_rate or 0
        colour_available = Reverie.find_used_cine("Every Hue") and not crazy_pack_available
        total_rate = total_rate + (colour_available and colour_rate or 0)
        table.insert(candidates,
            { type = "Colour", val = colour_available and colour_rate or 0, available = colour_available })
    end

    local polled_rate = pseudorandom(pseudoseed("cdt" .. G.GAME.round_resets.ante)) * total_rate
    local check_rate = 0

    -- sendDebugMessage("Joker Available: "..tostring(joker_available).." ("..(joker_available and G.GAME.joker_rate or 0)..")", "ReverieDebugLogger")
    -- sendDebugMessage("Planet or Tarot Available: "..tostring(planet_or_tarot_available).." ("..(planet_or_tarot_available and G.GAME.tarot_rate + G.GAME.planet_rate or 0)..")", "ReverieDebugLogger")
    -- sendDebugMessage("Playing Available: "..tostring(playing_available).." ("..(playing_available and playing_card_rate or 0)..")", "ReverieDebugLogger")
    -- sendDebugMessage("Spectral Available: "..tostring(spectral_available).." ("..(spectral_available and spectral_rate or 0)..")", "ReverieDebugLogger")
    -- sendDebugMessage("Tag Available: "..tostring(tag_available).." ("..(tag_available and G.GAME.joker_rate or 0)..")", "ReverieDebugLogger")
    -- sendDebugMessage("Crazy Pack Available: "..tostring(crazy_pack_available).." ("..(crazy_pack_available and G.GAME.joker_rate or 0)..")", "ReverieDebugLogger")

    -- if has_oddity then
    --     sendDebugMessage("Oddity Available: "..tostring(oddity_available).." ("..(oddity_available and oddity_rate or 0)..")", "ReverieDebugLogger")
    -- end

    -- if has_alchemical then
    --     sendDebugMessage("Alchemical Available: "..tostring(alchemical_available).." ("..(alchemical_available and alchemical_rate or 0)..")", "ReverieDebugLogger")
    -- end

    -- if has_colour then
    --     sendDebugMessage("Colour Available: "..tostring(colour_available).." ("..(colour_available and colour_rate or 0)..")", "ReverieDebugLogger")
    -- end

    -- sendDebugMessage("Total Rate: "..total_rate..", Polled Rate: "..polled_rate, "ReverieDebugLogger")

    for _, v in ipairs(candidates) do
        -- sendDebugMessage("Checking: "..v.type..", Available: "..tostring(v.available)..", Polled Rate("..polled_rate..
        --     ") <= Check Rate("..check_rate..") + Val("..v.val..") = ("..check_rate + v.val..")", "ReverieDebugLogger")

        if v.available and polled_rate > check_rate and polled_rate <= check_rate + v.val then
            -- sendDebugMessage(v.type.." selected", "ReverieDebugLogger")

            local card = nil

            if v.type == "Joker" then
                card = Reverie.create_special_joker(area)
            elseif Reverie.find_used_cine("Poker Face") and (v.type == "Enhanced" or v.type == "Base") then
                card = Reverie.create_poker_face_card(area)
            elseif Reverie.find_used_cine("Eerie Inn") and v.type == "Spectral" then
                local poll = pseudorandom("cine_spectral_size")
                local grade = poll >= 0.95 and "mega" or poll >= 0.75 and "jumbo" or "normal"
                local index = grade == "normal" and math.random(1, 2) or 1

                card = Reverie.create_booster(area, G.P_CENTERS["p_spectral_" .. grade .. "_" .. index])
            elseif v.type == "Tag" then
                card = Reverie.create_tag_as_card(area)
            elseif v.type == "Crazy" then
                card = Reverie.create_booster(area, G.P_CENTERS.p_dvrprv_crazy_lucky_1)
            end

            if not card then
                card = create_card(v.type, area, nil, nil, nil, nil, nil, "sho")
            end

            create_shop_card_ui(card, v.type, area)

            if Reverie.find_used_cine("Adrifting") and #G.GAME.current_round.used_cine == 1 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, vv in ipairs(G.GAME.tags) do
                            if vv:apply_to_run({
                                    type = "store_joker_modify",
                                    card = card
                                }) then
                                break
                            end
                        end

                        return true
                    end
                }))
            end

            if not Reverie.find_used_cine("Gem Heist") and (not Reverie.find_used_cine("Poker Face") or not card.edition)
                and (v.type == "Base" or v.type == "Enhanced") and G.GAME.used_vouchers.v_illusion
                and pseudorandom(pseudoseed("illusion")) > 0.8 then
                local edition_poll = pseudorandom(pseudoseed("illusion"))
                local edition = {}
                if edition_poll > 1 - 0.15 then
                    edition.polychrome = true
                elseif edition_poll > 0.5 then
                    edition.holo = true
                else
                    edition.foil = true
                end

                card:set_edition(edition)
            end

            return card
        end

        if v.available then
            check_rate = check_rate + v.val
        end
    end
end

local emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    Reverie.set_card_back(card)

    if self == G.consumeables and (card.ability.set == "Cine" or card.config.center.key == "c_dvrprv_reverie") then
        G.cine_quests:emplace(card, location, stay_flipped)

        return
    end

    emplace_ref(self, card, location, stay_flipped)

    if card.ability.booster_pos then
        G.GAME.current_round.max_boosters = math.max(G.GAME.current_round.max_boosters or 0, card.ability.booster_pos)
    end

    if self == G.shop_jokers or self == G.shop_vouchers or self == G.shop_booster or self == G.pack_cards then
        local unseen, heist = Reverie.find_used_cine("The Unseen"), Reverie.find_used_cine("Gem Heist")
        local is_dx_tarot_planet = Reverie.find_mod("JeffDeluxeConsumablesPack") and card.ability.set == "Planet"
        local is_bunco_consumable = Reverie.find_mod("Bunco") and card.ability.consumeable
        local editions = {}

        if heist and (card.ability.set == "Joker" or is_dx_tarot_planet or is_bunco_consumable or card.ability.set == "Default" or card.ability.set == "Enhanced") then
            table.insert(editions, "polychrome")
        end
        if unseen and (card.ability.set == "Joker" or card.ability.consumeable) then
            table.insert(editions, "negative")
        end

        if #editions > 0 then
            local edition = pseudorandom_element(editions, pseudoseed("edition"))
            card:set_edition({
                [edition] = true
            })
        elseif card.ability.set == "Cine" and card.ability.progress and G.GAME.selected_sleeve
            and G.GAME.selected_sleeve == "sleeve_dvrprv_filmstrip" and G.GAME.selected_back.name == "Filmstrip Deck" then
            local odds = CardSleeves.Sleeve:get_obj(G.GAME.selected_sleeve).config.odds

            if pseudorandom("filmstrip_sleeve") < G.GAME.probabilities.normal / odds then
                card:set_edition("e_negative")
            end
        end

        -- if heist then
        --     card.cost = math.max(1, math.floor(card.cost * (100 - G.P_CENTERS.c_dvrprv_gem_heist.config.extra.discount) / 100))
        --     card.sell_cost = math.max(1, math.floor(card.cost / 2)) + (card.ability.extra_value or 0)
        -- end

        if Reverie.find_used_cine("Morsel") and Reverie.is_food_joker(card.config.center.key) then
            card.ability.morseled = true
            Reverie.double_ability(card.config.center.config, card.ability)
        end

        if Reverie.find_used_cine("Every Hue") and card.ability.set == "Colour" then
            local rounds = G.P_CENTERS.c_dvrprv_every_hue.config.extra.rounds
            card.ability.extra = math.floor(rounds / card.ability.upgrade_rounds)
            card.ability.partial_rounds_held = rounds % card.ability.upgrade_rounds

            if card.ability.name == "Yellow" and card.ability.extra > 0 then
                card.ability.extra_value = card.ability.extra_value + (8 * card.ability.extra)
                card:set_cost()
            end
        end

        for _, v in ipairs(G.GAME.current_round.used_cine or {}) do
            local center = Reverie.find_cine_center(v)
    
            if center and type(center.config.extra) == "table" and center.config.extra.set_price then
                card.cost = center.config.extra.set_price
                card.sell_cost = math.floor(center.config.extra.set_price / 2)
            end
            if center and type(center.config.extra) == "table" and center.config.extra.discount then
                card.cost = math.max(1, math.floor(card.cost * (100 - center.config.extra.discount) / 100))
                card.sell_cost = math.max(1, math.floor(card.cost / 2)) + (card.ability.extra_value or 0)
            end
        end

        if Reverie.find_used_cine("Adrifting") and self ~= G.pack_cards then
            -- card.cost = G.P_CENTERS.c_dvrprv_adrifting.config.extra
            -- card.sell_cost = G.P_CENTERS.c_dvrprv_adrifting.config.extra
            -- Slight Bunco synergy, Fluorescent cards will be visible with Adrifting
            if not (card.edition and card.edition.bunc_fluorescent) then
                card.facing = "back"
                card.sprite_facing = "back"
                card.pinch.x = false
            end
        elseif Reverie.find_used_cine("Crazy Lucky") and self == G.shop_booster and card.config.center.kind ~= "Crazy" then
            local c = self:remove_card(card)
            c:remove()
            c = nil

            card = Reverie.create_booster(self, G.P_CENTERS.p_dvrprv_crazy_lucky_1)
            emplace_ref(self, card, location, stay_flipped)
        end
    end
end

function Reverie.calculate_reroll_cost()
    if not G.GAME.current_round.used_cine then
        return
    end

    local add = 0

    for _, v in ipairs(G.GAME.current_round.used_cine) do
        local center = Reverie.find_cine_center(v)

        if center and type(center.config.extra) == "table" then
            if center.config.extra.mult then
                G.GAME.current_round.reroll_cost = math.max(0,
                    math.floor(G.GAME.current_round.reroll_cost * center.config.extra.mult))
            elseif center.config.extra.add then
                add = add + center.config.extra.add
            end
        end
    end

    G.GAME.current_round.reroll_cost = G.GAME.current_round.reroll_cost + add
end

function Reverie.set_cine_banned_keys()
    for k, v in pairs(G.P_CENTERS) do
        if (v.yes_pool_flag == "Tag or Die" and G.GAME.selected_back.name ~= "" and not Reverie.config.tag_packs_shop)
            or (v.yes_pool_flag == "Crazy Lucky" and not Reverie.config.crazy_packs_shop) then
            G.GAME.banned_keys[k] = not Reverie.find_used_cine(v.yes_pool_flag)
        end
    end
end

local get_pack_ref = get_pack
function get_pack(_key, _type)
    local pack = get_pack_ref(_key, _type)

    -- For the compatibility with Betmma's Vouchers
    if not _type and G.GAME.current_round.used_cine then
        local kinds = Reverie.get_used_cine_kinds()

        if kinds then
            local found = false

            for _, v in ipairs(kinds) do
                if pack.key:find(v) then
                    found = true

                    break
                end
            end

            if not found then
                pack = Reverie.get_pack_by_slug(_key, pseudorandom_element(kinds, pseudoseed("cine_booster")))
            end
        end
    end

    return pack
end

function Reverie.get_pack_by_slug(key, slug)
    local cume, it, center = 0, 0, nil

    for _, v in ipairs(G.P_CENTER_POOLS.Booster) do
        if v.key:find(slug) and not G.GAME.banned_keys[v.key] then
            cume = cume + (v.weight or 1)
        end
    end

    local poll = pseudorandom(pseudoseed((key or "pack_generic") .. G.GAME.round_resets.ante)) * cume

    for _, v in ipairs(G.P_CENTER_POOLS.Booster) do
        if not G.GAME.banned_keys[v.key] then
            if v.key:find(slug) then
                it = it + (v.weight or 1)
            end

            if it >= poll and it - (v.weight or 1) <= poll then
                center = v
                break
            end
        end
    end

    return center
end

function Reverie.ban_modded_consumables()
    -- For modded consumables compatibility, banning them from appearing in Cine shop
    if Reverie.is_cine_forcing_card_set() then
        if G.GAME.oddity_rate then
            G.GAME.cached_oddity_rate = G.GAME.oddity_rate
            G.GAME.oddity_rate = 0
        end

        if G.GAME.alchemical_rate and G.GAME.alchemical_rate > 0 then
            G.GAME.cached_alchemical_rate = G.GAME.alchemical_rate
            G.GAME.alchemical_rate = nil
        end
    end
end

function Reverie.adjust_shop_width()
    if not G.shop_jokers then
        return
    end

    local jokers = G.GAME.shop.joker_max
    G.shop_jokers.T.w = jokers * 1.02 * G.CARD_W * (jokers > 4 and 4 / jokers or 1)

    if G.shop then
        G.shop:recalculate()
    end
end

local change_shop_size_ref = change_shop_size
function change_shop_size(mod)
    change_shop_size_ref(mod)

    Reverie.adjust_shop_width()
end

local uidef_shop_ref = G.UIDEF.shop
function G.UIDEF.shop()
    local shop = uidef_shop_ref()

    Reverie.adjust_shop_width()

    return shop
end

function Reverie.use_cine(center, card, area, copier)
    local is_reverie = card.ability.name == "Reverie"

    if not G.GAME.current_round.used_cine then
        G.GAME.current_round.used_cine = {}
    end

    inc_career_stat('c_Reverie_cines_used', 1)
    check_for_unlock({ type = 'career_stat', statname = 'c_Reverie_cines_used' })

    local top_dynatext = nil
    local bot_dynatext = nil
    local torn_strip = nil

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()

            card.no_shadow = true
            card.reverie_custom_shadow = true
            torn_strip = copy_card(card)
            torn_strip.no_shadow = true
            torn_strip.reverie_custom_shadow = true
            torn_strip.omit_bottom_half = 1
            card.omit_top_half = 1
            torn_strip.T.y = torn_strip.T.y - 0.1
            -- torn_strip.T.x = torn_strip.T.x + 0.1
            -- torn_strip.T.r = torn_strip.T.r + 3.14 / 24 -- Rotates clockwise
            G.play.T.y = G.play.T.y + 0.1
            -- card.T.y = card.T.y + 0.25
            -- G.play:emplace(torn_strip)


            top_dynatext = DynaText({
                string = localize('k_dvrprv_redeemed_cine'),
                colours = { G.C.WHITE },
                rotate = 1,
                shadow = true,
                bump = true,
                float = true,
                scale = 0.9,
                pop_in = 0.6 /
                    G.SPEEDFACTOR,
                pop_in_rate = 1.5 * G.SPEEDFACTOR
            })
            bot_dynatext = DynaText({
                string = localize { type = 'name_text', set = card.config.center.set, key = card.config.center.key },
                colours = { is_reverie and lighten(G.C.RARITY[4], 0.5) or G.C.WHITE },
                rotate = 2,
                shadow = true,
                bump = true,
                float = true,
                scale = 0.9,
                pop_in = 1.4 /
                    G.SPEEDFACTOR,
                pop_in_rate = 1.5 * G.SPEEDFACTOR * (is_reverie and 0.5 or 1),
                pitch_shift = 0.25
            })
            torn_strip:juice_up(0.3, 0.5)
            card:juice_up(0.3, 0.5)
            play_sound('card1')

            card.children.top_disp = UIBox {
                definition = { n = G.UIT.ROOT, config = { align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15 }, nodes = {
                    { n = G.UIT.O, config = { object = top_dynatext } }
                } },
                config = { align = "tm", offset = { x = 0, y = -0.3 }, parent = G.play }
            }
            card.children.bot_disp = UIBox {
                definition = { n = G.UIT.ROOT, config = { align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15 }, nodes = {
                    { n = G.UIT.O, config = { object = bot_dynatext } }
                } },
                config = { align = "bm", offset = { x = 0, y = 0 }, parent = G.play }
            }

            if is_reverie and not G.booster_pack_meteors then
                ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
                G.booster_pack_meteors = Particles(1, 1, 0, 0, {
                    timer = 0.035,
                    scale = 0.1,
                    lifespan = 1.5,
                    speed = 4,
                    attach = G.ROOM_ATTACH,
                    colours = { lighten(G.C.SECONDARY_SET.Cine, 0.2), G.C.WHITE },
                    fill = true
                })
            end

            return true
        end
    }))

    delay(0.6)

    G.E_MANAGER:add_event(Event({
        trigger = "immediate",
        func = function()
            if is_reverie then
                table.insert(G.GAME.current_round.used_cine, "Reverie")

                for _, v in pairs(G.P_CENTERS) do
                    if v.set == "Cine" then
                        table.insert(G.GAME.current_round.used_cine, v.name)
                    end
                end
            elseif G.GAME.selected_back.name == "Filmstrip Deck" or (G.GAME.selected_sleeve and G.GAME.selected_sleeve == "sleeve_dvrprv_filmstrip") then
                table.insert(G.GAME.current_round.used_cine, card.ability.name)
            elseif not Reverie.find_used_cine(card.ability.name) then
                G.GAME.current_round.used_cine = {
                    card.ability.name
                }
            end

            calculate_reroll_cost(true)
            Reverie.calculate_reroll_cost()

            if (is_reverie or card.ability.name == "Fool Metal Alchemist") and G.P_CENTERS.c_dvrprv_alchemist
                and not G.GAME.current_round.cine_temporary_consumeable_limit then
                G.GAME.current_round.cine_temporary_consumeable_limit = true
                G.consumeables.config.card_limit = G.consumeables.config.card_limit +
                    G.P_CENTERS.c_dvrprv_alchemist.config.extra.slot
            end

            if G.GAME.used_vouchers.v_dvrprv_script and not G.GAME.current_round.cine_temporary_shop_card_limit then
                G.GAME.current_round.cine_temporary_shop_card_limit = true
                G.GAME.shop.joker_max = G.GAME.shop.joker_max + G.P_CENTERS.v_dvrprv_script.config.extra
                G.shop_jokers.config.card_limit = G.GAME.shop.joker_max

                Reverie.adjust_shop_width()
            end

            Reverie.ban_modded_consumables()
            Reverie.set_cine_banned_keys()

            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = "immediate",
        func = function()
            -- Manipulate Jokers
            for i = #G.shop_jokers.cards, 1, -1 do
                local c = G.shop_jokers:remove_card(G.shop_jokers.cards[i])
                c:remove()
                c = nil
            end

            for _ = 1, G.GAME.shop.joker_max - #G.shop_jokers.cards do
                G.shop_jokers:emplace(Reverie.create_card_for_cine_shop(G.shop_jokers))
            end

            -- Manipulate vouchers
            for _, v in ipairs(G.shop_vouchers.cards) do
                if card.ability.name == "Adrifting" then
                    v.cost = G.P_CENTERS.c_dvrprv_adrifting.config.extra.set_price
                    v:flip()
                elseif is_reverie or card.ability.name == "Crazy Lucky" then
                    local c = G.shop_vouchers:remove_card(v)
                    c:remove()
                    c = nil

                    G.shop_vouchers:emplace(Reverie.create_card_for_cine_shop(G.shop_vouchers))
                end
            end

            local kinds, kind = Reverie.get_used_cine_kinds(), nil

            -- Manipulate boosters if needed
            if Reverie.find_used_cine("Adrifting") or kinds then
                for i = #G.shop_booster.cards, 1, -1 do
                    local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
                    c:remove()
                    c = nil
                end

                for i = 1, G.GAME.current_round.max_boosters do
                    local card = nil

                    if kinds then
                        kind = pseudorandom_element(kinds, pseudoseed("cine_booster"))
                    end

                    G.GAME.current_round.used_packs = {}
                    if not G.GAME.current_round.used_packs[i] then
                        G.GAME.current_round.used_packs[i] = kind and Reverie.get_pack_by_slug("shop_pack", kind).key or
                            get_pack("shop_pack").key
                    end

                    if G.GAME.current_round.used_packs[i] ~= "USED" then
                        card = Reverie.create_booster(G.shop_booster, G.P_CENTERS[G.GAME.current_round.used_packs[i]])
                    end

                    card.ability.booster_pos = i
                    card:start_materialize()
                    G.shop_booster:emplace(card)
                end
            end

            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 2.6,
        func = function()
            top_dynatext:pop_out(4)
            bot_dynatext:pop_out(4)
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.5,
        func = function()
            card.children.top_disp:remove()
            card.children.top_disp = nil
            card.children.bot_disp:remove()
            card.children.bot_disp = nil
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        blocking = false,
        func = function()
            if torn_strip then
                torn_strip:start_dissolve()
            end
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 2,
        blocking = false,
        func = function()
            if torn_strip then
                G.play.T.y = G.play.T.y - 0.25
            end
            return true
        end
    }))
end

Card.card_open_reverie_ref = Card.open
function Card:open()
    if self.ability.set == "Booster" and G.shop and G.booster_pack_meteors then
        G.booster_pack_meteors:fade(0)
    end

    self:card_open_reverie_ref()
end

Card.card_explode_reverie_ref = Card.explode
function Card:explode(dissolve_colours, explode_time_fac)
    self:card_explode_reverie_ref(dissolve_colours, explode_time_fac)

    if G.cine_quests and self.ability.set == "Booster" then
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in ipairs(G.cine_quests.cards) do
                    v:calculate_joker({
                        open_booster = true,
                        card = self
                    })
                end

                return true
            end
        }))
    end
end

Tag.tag_apply_to_run_reverie_ref = Tag.apply_to_run
function Tag:apply_to_run(_context)
    if G.GAME.current_round.used_cine and _context.type == "new_blind_choice" then
        return
    end

    return self:tag_apply_to_run_reverie_ref(_context)
end

Game.update_shop_reverie_ref = Game.update_shop
function Game:update_shop(dt)
    self:update_shop_reverie_ref(dt)

    if G.STATE_COMPLETE then
        for _, v in ipairs(G.GAME.tags) do
            v:apply_to_run({
                type = "immediate"
            })
        end
    end

    if Reverie.find_used_cine("Reverie") and not G.booster_pack_meteors then
        ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
        G.booster_pack_meteors = Particles(1, 1, 0, 0, {
            timer = 0.035,
            scale = 0.1,
            lifespan = 1.5,
            speed = 4,
            attach = G.ROOM_ATTACH,
            colours = { lighten(G.C.SECONDARY_SET.Cine, 0.2), G.C.WHITE },
            fill = true
        })
    end
end

local toggle_shop_ref = G.FUNCS.toggle_shop
function G.FUNCS.toggle_shop(e)
    toggle_shop_ref(e)

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.6,
        func = function()
            Reverie.end_cine_shop()

            if G.booster_pack_meteors then
                G.booster_pack_meteors:fade(0)
            end

            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0,
                blocking = false,
                blockable = false,
                func = function()
                    if G.booster_pack_meteors then
                        G.booster_pack_meteors:remove()
                        G.booster_pack_meteors = nil
                    end

                    return true
                end
            }))

            return true
        end
    }))
end

Card.check_use_reverie_ref = Card.check_use
function Card:check_use()
    if G.STATE == G.STATES.SMODS_BOOSTER_OPENED and SMODS.OPENED_BOOSTER.config.center.name == "Pack" then
        return nil
    end

    return self:check_use_reverie_ref()
end

function G.FUNCS.can_select_crazy_card(e)
    local is_cine = Reverie.is_cine_or_reverie(e.config.ref_table)

    -- Copy pasted from G.FUNCS.check_for_buy_space
    if e.config.ref_table.ability.set ~= "Voucher" and e.config.ref_table.ability.set ~= "Tag"
        and e.config.ref_table.ability.set ~= "Enhanced" and e.config.ref_table.ability.set ~= "Default"
        and not (e.config.ref_table.ability.set == "Joker" and #G.jokers.cards < G.jokers.config.card_limit +
            ((e.config.ref_table.edition and e.config.ref_table.edition.negative) and 1 or 0))
        and not (e.config.ref_table.ability.consumeable and not is_cine and #G.consumeables.cards < G.consumeables.config.card_limit +
            ((e.config.ref_table.edition and e.config.ref_table.edition.negative) and 1 or 0))
        and not (is_cine and #G.cine_quests.cards < G.cine_quests.config.card_limit +
            ((e.config.ref_table.edition and e.config.ref_table.edition.negative) and 1 or 0)) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.GREEN
        e.config.button = "use_card"
    end
end

local can_select_card_ref = G.FUNCS.can_select_card
function G.FUNCS.can_select_card(e)
    can_select_card_ref(e)

    if Reverie.is_cine_or_reverie(e.config.ref_table) and not (e.config.ref_table.edition and e.config.ref_table.edition.negative)
        and #G.cine_quests.cards >= G.cine_quests.config.card_limit then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

local use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local result = use_and_sell_buttons_ref(card)

    if (Reverie.is_cine_or_reverie(card) or Reverie.find_used_cine("Crazy Lucky")) and card.ability.consumeable and card.area and card.area == G.pack_cards then
        return {
            n = G.UIT.ROOT,
            config = { padding = 0, colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5 * card.T.w - 0.15, maxw = 0.9 * card.T.w - 0.15, minh = 0.3 * card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_select_crazy_card' },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize('b_select'), colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true } }
                    }
                } }
        }
    end

    return result
end

local card_focus_ui_ref = G.UIDEF.card_focus_ui
function G.UIDEF.card_focus_ui(card)
    local base_background = card_focus_ui_ref(card)
    local base_attach = base_background:get_UIE_by_ID("ATTACH_TO_ME")
    local card_width = card.T.w + (card.ability.consumeable and -0.1 or card.ability.set == "Voucher" and -0.16 or 0)

    if Reverie.find_used_cine("Crazy Lucky") and card.area == G.pack_cards and G.pack_cards then
        base_attach.children.use = G.UIDEF.card_focus_button {
            card = card, parent = base_attach, type = "select",
            func = "can_select_crazy_card", button = "use_card", card_width = card_width
        }
    elseif card.ability.set == "Booster" and (card.area == G.shop_jokers or card.area == G.shop_vouchers) then
        base_attach.children.buy = nil
        base_attach.children.redeem = G.UIDEF.card_focus_button {
            card = card, parent = base_attach, type = "buy",
            func = "can_open", button = "open_booster", card_width = card_width * 0.85
        }
    elseif card.ability.set == "Cine" then
        if card.area == G.pack_cards and G.pack_cards then
            base_attach.children.use = G.UIDEF.card_focus_button {
                card = card, parent = base_attach, type = "select",
                func = "can_select_card", button = "use_card", card_width = card_width
            }
        elseif G.cine_quests and card.area == G.cine_quests and G.STATE ~= G.STATES.TUTORIAL then
            base_attach.children.use = G.UIDEF.card_focus_button {
                card = card, parent = base_attach, type = "use",
                func = "can_use_consumeable", button = "use_card", card_width = card_width
            }
            base_attach.children.sell = G.UIDEF.card_focus_button {
                card = card, parent = base_attach, type = "sell",
                func = "can_sell_card", button = "sell_card", card_width = card_width
            }
        end
    end

    return base_background
end

Controller.is_node_focusable_reverie_ref = Controller.is_node_focusable
function Controller:is_node_focusable(node)
    local ret_val = self:is_node_focusable_reverie_ref(node)

    if node:is(Card) and Reverie.find_used_cine("Adrifting") and node.facing == "back" then
        ret_val = true
    end

    return ret_val
end

local sell_card_ref = G.FUNCS.sell_card
function G.FUNCS.sell_card(e)
    local card = e.config.ref_table

    sell_card_ref(e)

    if G.cine_quests then
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in ipairs(G.cine_quests.cards) do
                    v:calculate_joker({
                        selling_card = true,
                        card = card
                    })
                end

                return true
            end
        }))
    end
end

Card.set_ability_reverie_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    local before_enhancements, after_enhancements = 0, 0

    if G.STAGE == G.STAGES.RUN and G.playing_cards then
        for _, v in pairs(G.playing_cards) do
            if v.config.center ~= G.P_CENTERS.c_base then
                before_enhancements = before_enhancements + 1
            end
        end
    end

    self:set_ability_reverie_ref(center, initial, delay_sprites)

    if self.ability.set == "Cine" and self.config.center.reward then
        self.ability.progress = 0

        if G.GAME.used_vouchers.v_dvrprv_megaphone then
            self.ability.extra.goal = Reverie.halve_cine_quest_goal(self.ability.extra.goal)
        end
    end

    if G.STAGE == G.STAGES.RUN and G.playing_cards then
        for _, v in pairs(G.playing_cards) do
            if v.config.center ~= G.P_CENTERS.c_base then
                after_enhancements = after_enhancements + 1
            end
        end
    end

    if G.cine_quests and not initial and center.set == "Enhanced" and before_enhancements < after_enhancements then
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in ipairs(G.cine_quests.cards) do
                    v:calculate_joker({
                        enhancing_card = true,
                        card = self
                    })
                end

                return true
            end
        }))
    end
end

Card.calculate_joker_reverie_ref = Card.calculate_joker
function Card:calculate_joker(context)
    if self.debuff then
        return nil
    end

    if self.ability.set == "Cine" and self.ability.progress then
        if (self.config.center.reward == "c_dvrprv_gem_heist" and context.selling_card and context.card.ability.set == "Joker" and context.card.edition)
            or (self.config.center.reward == "c_dvrprv_ive_no_shape" and context.end_of_round and not context.individual and not context.repetition
                and G.GAME.chips >= G.GAME.blind.chips * self.ability.extra.chips)
            or (self.config.center.reward == "c_dvrprv_unseen" and context.end_of_round and not context.individual and not context.repetition
                and G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer) >= self.ability.extra.slots)
            or (self.config.center.reward == "c_dvrprv_crazy_lucky" and context.open_booster)
            or (self.config.center.reward == "c_dvrprv_tag_or_die" and context.skip_blind)
            or (self.config.center.reward == "c_dvrprv_let_it_moon" and context.using_consumeable
                and (context.consumeable.ability.set == "Tarot" or context.consumeable.ability.set == "Planet"))
            or (self.config.center.reward == "c_dvrprv_poker_face" and context.enhancing_card)
            or (self.config.center.reward == "c_dvrprv_eerie_inn" and context.any_card_destroyed)
            or (self.config.center.reward == "c_dvrprv_adrifting" and context.debuff_or_flipped_played)
            or (self.config.center.reward == "c_dvrprv_morsel" and context.joker_added and Reverie.is_food_joker(context.card.config.center_key))
            or (self.config.center.reward == "c_dvrprv_alchemist" and context.using_consumeable and context.consumeable.ability.set == "Alchemical")
            or (self.config.center.reward == "c_dvrprv_very_hue" and context.using_consumeable and context.consumeable.ability.set == "Colour")
            or (self.config.center.reward == "c_dvrprv_radioactive" and context.joker_added and context.card.config.center.rarity == 5)
            or (self.config.center.reward == "c_dvrprv_jovial_m" and context.selling_card and context.card.config.center.key == "j_jolly") then
            return Reverie.progress_cine_quest(self)
        end
    end

    if self.ability.set == "Joker" and self.ability.morseled then
        if self.ability.name == "Diet Cola" and context.selling_self then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag("tag_double"))
                    play_sound("generic1", 0.9 + math.random() * 0.1, 0.8)
                    play_sound("holo1", 1.2 + math.random() * 0.1, 0.4)

                    return true
                end)
            }))
            delay(0.5)
        end

        if Reverie.config.custom_morsel_compat then
            if (self.config.center.key == "j_olab_mystery_soda" and context.selling_self)
                or (self.config.center.key == "j_evo_full_sugar_cola" and context.selling_self)
                or (self.config.center.key == "j_pape_ghost_cola" and context.selling_self)
                or (self.config.center.key == "j_jank_cut_the_cheese" and context.setting_blind)
                or (self.config.center.key == "j_mf_tonersoup" and context.cardarea == G.jokers and context.before) then
                self.config.center:calculate(self, context)
                delay(0.5)
            elseif self.config.center.key == "j_olab_fine_wine" and context.setting_blind and not context.getting_sliced and not context.blueprint then
                self.ability.extra.discards = self.ability.extra.discards + 1
            elseif self.config.center.key == "j_mf_goldencarrot" and context.after and context.cardarea == G.jokers and not context.blueprint then
                if not self.gone and type(self.ability.extra) == "number" and self.ability.extra - 1 > 0 then
                    self.ability.extra = self.ability.extra - 1
                end
            elseif self.config.center.key == "j_bunc_fondue" and context.after and G.GAME.current_round.hands_played == 1 and context.scoring_hand and not context.blueprint then
                enable_exotics()

                for i = 1, #context.scoring_hand do
                    G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.15, func = function()
                        context.scoring_hand[i]:flip(); play_sound("card1", 1); context.scoring_hand[i]:juice_up(0.3, 0.3); return true
                    end })
                end

                for i = 1, #context.scoring_hand do
                    G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.1, func = function()
                        context.scoring_hand[i]:change_suit("bunc_Fleurons"); return true
                    end })
                end

                for i = 1, #context.scoring_hand do
                    G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.15, func = function()
                        context.scoring_hand[i]:flip(); play_sound("tarot2", 1, 0.6); self:juice_up(0.7); context
                            .scoring_hand[i]:juice_up(0.3, 0.3); return true
                    end })
                end

                delay(0.7 * 1.25)
            end
        end
    end

    local result = self:calculate_joker_reverie_ref(context)

    if self.ability.set == "Joker" and self.ability.morseled then
        if self.config.center.key == "j_kcva_swiss" and context.after and not context.blueprint then
            card_eval_status_text(self, "extra", nil, nil, nil, {
                message = localize {
                    type = "variable",
                    key = "a_mult",
                    vars = { self.ability.mult }
                },
                colour = G.C.MULT
            });

            self.ability.mult = self.ability.mult * 2
        end
    end

    return result
end

function Reverie.progress_cine_quest(card)
    if not card.ability.progress then
        return
    end

    card.ability.progress = card.ability.progress + 1

    if card.ability.progress <= card.ability.extra.goal then
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = card.ability.progress .. "/" .. card.ability.extra.goal,
            colour = G.C.SECONDARY_SET.Cine
        })
    end
    if card.ability.progress >= card.ability.extra.goal then
        Reverie.complete_cine_quest(card)
    end

    SMODS.calculate_context({ cine_progress = true, card = card })
end

function Reverie.complete_cine_quest(card)
    if card.flipping or not card.ability.progress then return end -- Safety check

    local orig_pos = card.config.center.pos
    card:set_ability(G.P_CENTERS[card.config.center.reward], true)
    card.children.center:set_sprite_pos(orig_pos)

    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME.used_jokers[card.config.center_key] = nil
            card.config.card = {}
            local percent = 1.15 - (1 - 0.999) / (1 - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.15,
                func = function()
                    if card.flipping then return end -- Safety check
                    card:flip()
                    play_sound("card1", percent)
                    card:juice_up(0.3, 0.3)

                    return true
                end
            }))
            return true
        end
    }))
    G.E_MANAGER:add_event(Event({
        func = function()
            if Reverie.find_mod("JokerDisplay") and _G["JokerDisplay"] and Reverie.config.jokerdisplay_compat then
                if card.flipping then return end -- Safety check
                card.joker_display_values.disabled = true
            end
            return true
        end
    }))
end

Tag.tag_init_reverie_ref = Tag.init
function Tag:init(_tag, for_collection, _blind_type)
    self:tag_init_reverie_ref(_tag, for_collection, _blind_type)

    local proto = G.P_TAGS[_tag] or G.tag_undiscovered
    if proto.atlas then
        self.atlas = proto.atlas
    end
end

Tag.tag_load_reverie_ref = Tag.load
function Tag:load(tag_savetable)
    local proto = G.P_TAGS[tag_savetable.key] or G.tag_undiscovered
    if proto.atlas then
        self.atlas = proto.atlas
    end

    self:tag_load_reverie_ref(tag_savetable)
end

Card.card_highlight_reverie_ref = Card.highlight
function Card:highlight(is_higlighted)
    self:card_highlight_reverie_ref(is_higlighted)

    if Reverie.is_cine_or_reverie(self) or (self.area and self.area == G.pack_cards) then
        if self.highlighted and self.area and self.area.config.type ~= 'shop' then
            local x_off = (self.ability.consumeable and -0.1 or 0)
            self.children.use_button = UIBox {
                definition = G.UIDEF.use_and_sell_buttons(self),
                config = { align =
                    ((self.area == G.jokers) or (self.area == G.consumeables) or (self.area == G.cine_quests)) and "cr" or
                    "bmi"
                , offset =
                    ((self.area == G.jokers) or (self.area == G.consumeables) or (self.area == G.cine_quests)) and { x = x_off - 0.4, y = 0 } or
                    { x = 0, y = 0.65 },
                    parent = self }
            }
        elseif self.children.use_button then
            self.children.use_button:remove()
            self.children.use_button = nil
        end
    end
end

local skip_blind_ref = G.FUNCS.skip_blind
function G.FUNCS.skip_blind(e)
    if G.cine_quests and e.UIBox:get_UIE_by_ID("tag_container") then
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in ipairs(G.cine_quests.cards) do
                    v:calculate_joker({
                        skip_blind = true
                    })
                end

                return true
            end
        }))
    end

    skip_blind_ref(e)
end

local use_card_ref = G.FUNCS.use_card
function G.FUNCS.use_card(e)
    local card = e.config.ref_table
    local is_consumeable = card.ability.consumeable

    use_card_ref(e)

    if G.cine_quests and is_consumeable then
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in ipairs(G.cine_quests.cards) do
                    v:calculate_joker({
                        using_consumeable = true,
                        consumeable = card
                    })
                end

                return true
            end
        }))
    end
end

local end_round_ref = end_round
function end_round()
    end_round_ref()

    if G.cine_quests and G.STATE ~= G.STATES.GAME_OVER then
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in ipairs(G.cine_quests.cards) do
                    v:calculate_joker({
                        end_of_round = true
                    })
                end

                return true
            end
        }))
    end
end

Card.add_to_deck_reverie_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    self:add_to_deck_reverie_ref(from_debuff)

    if G.cine_quests and self.ability.set == "Joker" then
        for _, v in ipairs(G.cine_quests.cards) do
            v:calculate_joker({
                joker_added = true,
                card = self
            })
        end
    end
end

Card.card_sell_card_reverie_ref = Card.sell_card
function Card:sell_card()
    self.ability.not_destroyed = true

    self:card_sell_card_reverie_ref()
end

Card.card_remove_reverie_ref = Card.remove
function Card:remove()
    local destroyed = (self.added_to_deck and not self.ability.not_destroyed) or (G.playing_cards and self.playing_card)
    local on_game_area = nil

    for k, v in pairs(G) do
        if type(v) == "table" and v.is and v:is(CardArea) and self.area == v then
            on_game_area = true
            break
        end
    end

    self:card_remove_reverie_ref()

    if G.cine_quests and destroyed and on_game_area then
        for _, v in ipairs(G.cine_quests.cards) do
            if v ~= self then
                v:calculate_joker({
                    any_card_destroyed = true,
                    card = self
                })
            end
        end
    end
end

local play_cards_from_highlighted_ref = G.FUNCS.play_cards_from_highlighted
function G.FUNCS.play_cards_from_highlighted(e)
    if G.play and G.play.cards[1] then
        return
    end

    for _, v in ipairs(G.hand.highlighted) do
        if G.cine_quests and (v.debuff or v.facing == "back") then
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _, v in ipairs(G.cine_quests.cards) do
                        v:calculate_joker({
                            debuff_or_flipped_played = true,
                            card = v
                        })
                    end

                    return true
                end
            }))
        end
    end

    play_cards_from_highlighted_ref(e)
end

function Reverie.set_card_back(card)
    if not card or G.STAGE ~= G.STAGES.RUN then
        return
    end

    -- Bunco blind pack compatibility
    if card.ability.blind_card then
        return
    end

    if card.ability.set == "Alchemical" or card.ability.set == "Default" or card.ability.set == "Enhanced" then
        card.children.back.atlas = G.ASSET_ATLAS[G.GAME.selected_back.atlas or "centers"]
        card.children.back:set_sprite_pos(G.GAME.selected_back.pos)
    elseif card.ability.set == "Voucher" then
        card.children.back.atlas = G.ASSET_ATLAS["dvrprv_cine_vouchers"]
        card.children.back:set_sprite_pos(Reverie.flipped_voucher_pos)
    elseif card.ability.set == "Tag" then
        card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["dvrprv_cine_tags"],
            Reverie.flipped_tag_pos)
        card.children.back.states.hover = card.states.hover
        card.children.back.states.click = card.states.click
        card.children.back.states.drag = card.states.drag
        card.children.back.states.collide.can = false
        card.children.back:set_role({ major = card, role_type = "Glued", draw_major = card })
    elseif card.ability.set == "Booster" then
        card.children.back.atlas = G.ASSET_ATLAS["dvrprv_cine_boosters"]
        card.children.back:set_sprite_pos(Reverie.flipped_booster_pos)
    end
end

Card.card_load_reverie_ref = Card.load
function Card:load(cardTable, other_card)
    if cardTable.label == "Tag" then
        G.P_CENTERS[cardTable.save_fields.center] = G.P_TAGS[cardTable.save_fields.center]
    end

    self:card_load_reverie_ref(cardTable, other_card)

    if cardTable.label == "Tag" then
        G.P_CENTERS[cardTable.save_fields.center] = nil

        self.T.h = 0.8
        self.T.w = 0.8
        self.VT.h = self.T.H
        self.VT.w = self.T.w

        self.ability.tag = Tag(self.config.center_key)
        self.ability.tag.ability.as_card = true

        if self.ability.name == "Orbital Tag" then
            self.ability.tag.ability.orbital_hand = self.ability.orbital
        end
    end

    Reverie.set_card_back(self)
end

local generate_UIBox_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
    if self.ability.set == "Tag" then
        self.ability.tag:generate_UI()
        return self.ability.tag:get_uibox_table().ability_UIBox_table
    end

    return generate_UIBox_ability_table_ref(self)
end

local cash_out_ref = G.FUNCS.cash_out
function G.FUNCS.cash_out(e)
    cash_out_ref(e)

    G.GAME.selected_back:trigger_effect({
        context = "setting_tags"
    })

    if G.GAME.selected_sleeve then
        CardSleeves.Sleeve:get_obj(G.GAME.selected_sleeve or "sleeve_casl_none"):trigger_effect({
            context = "setting_tags"
        })
    end
end

function Reverie.halve_cine_quest_goal(value)
    return math.max(1, math.floor(value * G.P_CENTERS.v_dvrprv_megaphone.config.extra))
end

function Reverie.is_in_reverie_pack()
    for _, v in ipairs(Reverie.boosters) do
        if G.STATE == G.STATES.SMODS_BOOSTER_OPENED and v.name == SMODS.OPENED_BOOSTER.config.center.name then
            return true
        end
    end
end

local check_for_buy_space_ref = G.FUNCS.check_for_buy_space
function G.FUNCS.check_for_buy_space(card)
    if Reverie.is_cine_or_reverie(card) and not (#G.cine_quests.cards < G.cine_quests.config.card_limit +
            ((card.edition and card.edition.negative) and 1 or 0)) then
        alert_no_space(card, G.cine_quests)

        return false
    end

    return check_for_buy_space_ref(card)
end

function Reverie.find_mod(id)
    for _, mod in ipairs(SMODS.find_mod(id)) do
        if mod.can_load then
            return true
        end
    end
    return false
end

if Reverie.find_mod("cartomancer") and Cartomancer then
    local expand_G_jokers_ref = Cartomancer.expand_G_jokers
    function Cartomancer.expand_G_jokers()
        local result = expand_G_jokers_ref()

        local self_T_w = math.max(4.9 * G.CARD_W, 0.6 * #G.cine_quests.cards * G.CARD_W)
        local self_T_x = G.jokers.T.x - (self_T_w - 4.9 * G.CARD_W) * G.jokers.cart_zoom_slider / 100

        local self = G.cine_quests

        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then
                card.T.r = 0.1 * (- #self.cards / 2 - 0.5 + k) / (#self.cards) +
                    (G.SETTINGS.reduced_motion and 0 or 1) * 0.02 * math.sin(2 * G.TIMERS.REAL + card.T.x)
                local max_cards = 1
                card.T.x = self_T_x +
                    (self_T_w - self.card_w) *
                    ((k - 1) / math.max(max_cards - 1, 1) - 0.5 * (#self.cards - max_cards) / math.max(max_cards - 1, 1)) +
                    0.5 * (self.card_w - card.T.w)
                if #self.cards > 2 or (#self.cards > 1 and self == G.consumeables) or (#self.cards > 1 and self.config.spread) then
                    card.T.x = self_T_x + (self_T_w - self.card_w) * ((k - 1) / (#self.cards - 1)) +
                        0.5 * (self.card_w - card.T.w)
                elseif #self.cards > 1 and self ~= G.consumeables then
                    card.T.x = self_T_x + (self_T_w - self.card_w) * ((k - 0.5) / (#self.cards)) +
                        0.5 * (self.card_w - card.T.w)
                else
                    card.T.x = self_T_x + self_T_w / 2 - self.card_w / 2 + 0.5 * (self.card_w - card.T.w)
                end
                local highlight_height = G.HIGHLIGHT_H / 2
                if not card.highlighted then highlight_height = 0 end
                card.T.y = self.T.y + self.T.h / 2 - card.T.h / 2 - highlight_height +
                    (G.SETTINGS.reduced_motion and 0 or 1) * 0.03 * math.sin(0.666 * G.TIMERS.REAL + card.T.x)
                card.T.x = card.T.x + card.shadow_parrallax.x / 30
            end
        end

        return result
    end

    local align_cards_ref = CardArea.align_cards
    function CardArea:align_cards()
        align_cards_ref(self)

        if self == G.cine_quests and G.jokers.cart_jokers_expanded then
            local align_cards = Cartomancer.expand_G_jokers()

            table.sort(self.cards,
                function(a, b)
                    return a.T.x + a.T.w / 2 - 100 * (a.pinned and a.sort_id or 0) <
                        b.T.x + b.T.w / 2 - 100 * (b.pinned and b.sort_id or 0)
                end)

            if align_cards then
                self:hard_set_cards()
            end
        end
    end
end
