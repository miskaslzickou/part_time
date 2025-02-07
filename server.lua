RegisterNetEvent('part_time:giveReward', function(reward)
    -- Zkontrolujte, zda je reward tabulka
    if type(reward) ~= 'table'  and #GetEntityCoords(GetPlayerPed(source),true) -#Config.DepoNPC.Location.xyz < 5.0 then -- distance check  a check jestli arg je table
       -- nějaká logika na log nebo ban hráče za podvádění
        return
    else
        reward_sum = 0
        for _, value in pairs(reward) do
            reward_sum += value

            
        end
        exports.ox_inventory:AddItem(source,'money',reward_sum)
    end

end)