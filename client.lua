local depoNPCLocation= Config.DepoNPC.Location
local isDoingJob=false
local reward={}

AddTextEntry('deliveryBlip', 'Doručování zásilek')
local deliveryBlip=AddBlipForCoord( 
    depoNPCLocation.x --[[ number ]], 
    depoNPCLocation.y --[[ number ]], 
	depoNPCLocation.z --[[ number ]]
	)

    BeginTextCommandSetBlipName('deliveryBlip')
   
    SetBlipSprite(
        deliveryBlip --[[ Blip ]], 
       Config.BlipSprite --[[ integer ]]
    )
    SetBlipColour(deliveryBlip,28)
    EndTextCommandSetBlipName(deliveryBlip)
local point = lib.points.new({
    coords=depoNPCLocation.xyz,
    distance=45,
})
function point:onEnter() -- využití client side static pedů je to lepší než přes server side 
    lib.requestModel(Config.DepoNPC.Model)
      DepoNPC=CreatePed(
		1--[[ integer ]], 
		joaat(Config.DepoNPC.Model) --[[ Hash ]], 
		depoNPCLocation.x --[[ number ]], 
		depoNPCLocation.y --[[ number ]], 
		depoNPCLocation.z --[[ number ]], 
		depoNPCLocation.w --[[ number ]], 
		false --[[ boolean ]], 
		false --[[ boolean ]]
	)
    FreezeEntityPosition(DepoNPC,true)
    SetEntityInvincible(DepoNPC,true)
    SetBlockingOfNonTemporaryEvents(DepoNPC,true)
    exports.ox_target:addLocalEntity(DepoNPC,{
        label="Promluvit s pánem",
        name="box_delivery",
        icon="fa-solid fa-truck-fast",
        distance=2,
        onSelect= function (data)
            lib.registerContext({
                id = 'delivery_menu',
                title = 'Doručovací služba',
                options = {
                  {
                    title = 'Začít pracovat/Vzít další zakázku',
                    
                    onSelect=function ()
                        if isDoingJob then
                        lib.notify({description='Nemůžeš začít práci už nějakou děláš',type='error'})
                        
                        else
                       
                        lib.requestModel(Config.Depo.VehicleModel)
                        for i=1,#Config.Depo.SpawnVehicleLocation-1 do
                            local spawnLoc=Config.Depo.SpawnVehicleLocation 
                            
                            if deliveryVehicle == nil then
                                if #lib.getNearbyVehicles(spawnLoc[i].xyz, 2.0) ==0 then
                                deliveryVehicle=CreateVehicle(
                                joaat(Config.Depo.VehicleModel) --[[ Hash ]], 
                                spawnLoc[i].x --[[ number ]], 
                                spawnLoc[i].y --[[ number ]], 
                                spawnLoc[i].z --[[ number ]], 
                                spawnLoc[i].w --[[ number ]], 
                                true --[[ boolean ]], 
                                true --[[ boolean ]]
                                )
                                end
                            else
                            break
                            end
                            
                        end
                        SetModelAsNoLongerNeeded(Config.Depo.VehicleModel)
                        if deliveryVehicle== nil then lib.notify({description='Parkoviště je plné zkus to později',type='error'}) return end
                        isDoingJob=true

                         pickupLocation=Config.Depo.PickupLocations[math.random(1,#Config.Depo.PickupLocations)]
                        
                        
                        AddTextEntry('pickupLocationBlip', 'Místo vyzvednutí')
                        local pickupLocationBlip=AddBlipForCoord(pickupLocation.x,pickupLocation.y,pickupLocation.z)
                        BeginTextCommandSetBlipName('pickupLocationBlip')
                        SetNewWaypoint(pickupLocation.x,pickupLocation.y)
                        EndTextCommandSetBlipName(pickupLocationBlip)
                        local pickupPoint = lib.points.new({
                            coords=pickupLocation.xyz,
                            distance=60,


                        })

                        function pickupPoint:onEnter()

                          
                            local pedModel=Config.PickupPedModel[math.random(#Config.PickupPedModel)] 
                            lib.requestModel(pedModel)

                             pickupPed=CreatePed(
                                1--[[ integer ]], 
                                joaat(pedModel) --[[ Hash ]], 
                                pickupLocation.x --[[ number ]], 
                                pickupLocation.y --[[ number ]], 
                                pickupLocation.z --[[ number ]], 
                                pickupLocation.w --[[ number ]], 
                                false --[[ boolean ]], 
                                false --[[ boolean ]]
                                )
                                
                                FreezeEntityPosition(pickupPed,true)
                                SetEntityInvincible(pickupPed,true)
                                SetBlockingOfNonTemporaryEvents(pickupPed,true)
                                exports.ox_target:addLocalEntity(pickupPed,{
                                    label='Vyzvednout zásilku',
                                    name='pickup_box',
                                    icon='fa-box',
                                    distance=2,
                                    onSelect=function(data)
                                   
                                    lib.requestAnimDict("mp_common")
                                    lib.requestModel('prop_cs_cardbox_01')
                                    local box=CreateObject(GetHashKey('prop_cs_cardbox_01'),pickupLocation.x,pickupLocation.y,pickupLocation.z,true,true,true)

                                    AttachEntityToEntity(box, pickupPed, 71, -0.085318464621196, 0.1162040589082, -0.20954139782074, 0, 0, 0, false, false, false, false, 2, true)
                                    Wait(1000)
                                    TaskPlayAnim(PlayerPedId(), "mp_common", "givetake1_a", 8.0, 8.0, -1, 1, 0, false, false, false)
                                    DetachEntity(box,true,true)

                                    AttachEntityToEntity(box, PlayerPedId(), 71, 0.14207805994636, 0.098469455842826, -0.28692043093302, 75.095927450467, -9.0896551973819, 25.016612882259, false, false, false, false, 2, true)
                                    TaskPlayAnim(pickupPed, "mp_common", "givetake1_b", 8.0, 8.0, -1, 1, 0, false, false, false)
                                    
                                    Wait(1000)
                                    ClearPedTasks(PlayerPedId())
                                    ClearPedTasks(pickupPed)
                                    
                                    lib.requestAnimDict("anim@heists@box_carry@") 
                                    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 49, 1.0, false, false, false)
                                    Wait(1000)
                                    
                                   
                                    lib.notify({description='Zásilka byla úspěšně vyzvednuta',type='success'})
                                    
                                    exports.ox_target:removeLocalEntity(pickupPed,"pickup_box")
                                    carryingBox=true
                                    RemoveAnimDict("mp_common")
                                    RemoveBlip(pickupLocationBlip)
                                    
                                    

                                    
                                    
                                    exports.ox_target:addLocalEntity(deliveryVehicle,{
                                        label='Dát do vozidla zásilku',
                                        name='delivery_vehicle',
                                        icon='fa-truck',
                                        distance=2,
                                        bones={'door_pside_r','seat_pside_r','seat_dside_r','door_dside_r'},
                                        onSelect=function(data)
                                            RemoveAnimDict("anim@heists@box_carry@")
                                            lib.notify({description='Zásilka byla dáno do vozidla',type='success'})
                                            DeleteEntity(box)
                                            SetModelAsNoLongerNeeded('prop_cs_cardbox_01')
                                            ClearPedTasks(PlayerPedId())
                                            SetNewWaypoint(Config.Depo.Location.x,Config.Depo.Location.y)
                                            carryingBox=false
                                            exports.ox_target:removeLocalEntity(deliveryVehicle,"delivery_vehicle")
                                            deliveryPoint=lib.points.new({
                                                coords=Config.Depo.Location.xyz,
                                                distance=25,
                                            })
                                            function deliveryPoint:onEnter()
                                                if DoesEntityExist(deliveryVehicle) and #GetEntityCoords(PlayerPedId(),true) -#GetEntityCoords(deliveryVehicle) <5.0 then
                                                lib.notify({description='Zásilka byla úspěšně doručena. Dojdi si pro odměnu nebo další zakázku',type='success'})
                                                
                                                table.insert(reward,math.random(50,100))
                                                deliveryPoint:remove()
                                                pickupPoint:remove()
                                               
                                               
                                                isDoingJob=false
                                                end
                                            end

                                        end
                                    })


                                end
                                    
                                })

                        end
                       
                        function pickupPoint:onExit()
                            exports.ox_target:removeLocalEntity(pickupPed,"pickup_box")
                            DeleteEntity(pickupPed)
                            if carryingBox then -- distance check jestli hráč opustí oblast
                                lib.notify({description='Zásilka byla ztracena/ opustil si oblast se zásilkou',type='error'})
                                carryingBox=false
                                DeleteEntity(box)
                                pickupPoint:remove()
                            end
                            
                        end
                       

                   
                      
                            
                        end
                    end
                },
                {
                    title='Přestat pracovat a vyzvednout odměnu',
                    onSelect=function ()
                        isDoingJob=false
                        DeleteEntity(deliveryVehicle)
                        if #reward==0 then
                            lib.notify({description='Nemáš žádnou odměnu',type='error'})
                        else
                            
                            TriggerServerEvent('part_time:giveReward',reward)
                            
                            reward={}
                        end
                    end
                }
               

                }
              })
             
              lib.showContext('delivery_menu')

        end

    })
    SetModelAsNoLongerNeeded(Config.DepoNPC.Model)

end
function point:onExit()
    exports.ox_target:removeLocalEntity(DepoNPC,"box_delivery")  
    DeleteEntity(DepoNPC) 
    

end

