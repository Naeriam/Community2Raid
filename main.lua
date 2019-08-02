SLASH_COMMUNITY2RAID1 = '/invitetoraid'
DEFAULT_CHAT_FRAME:AddMessage('[Community2Raid] Mass invite Community to Raid: /invitetoraid <CommunityName>', 1,1,0)

maxTime = 0
membersInChannels = {}

----------------------------
-- Invite Players
----------------------------
local function InviteToRaid()
    for _,memberID in pairs(membersInChannels) do
        memberInfo = C_Club.GetMemberInfo(communityID, memberID)
        if memberInfo.presence == Enum.ClubMemberPresence.Online then
            InviteUnit(memberInfo.name)
        end
    end
end

---------------------------------------------------------------------
-- Check if someone accepted invitation, so I can to convert to raid
---------------------------------------------------------------------
local function checkParty()

    if maxTime > 60 then --Invitation attempts end in 1 minute 
        return
    end

    numMembers = GetNumSubgroupMembers()

    if numMembers > 0 then
        ConvertToRaid()
        InviteToRaid() --Second invitation wave
    else
        maxTime = maxTime + 1
        C_Timer.After(1, checkParty) --Check all again in 1 second
    end

end

------------------------------------
-- Find Members of the Community
------------------------------------
local function InviteCommunity(input)

    communityName = input:match("%s*(.*)") --RegExp: space+<Community Name>

    communities = C_Club.GetSubscribedClubs()

    communityID = nil

    for _,community in pairs(communities) do
        if (community.name == communityName and community.clubType == 1) then
            communityID = community.clubId
        end
    end

    if communityID == nil then
        DEFAULT_CHAT_FRAME:AddMessage('[Community2Raid] Bad community name, please retry.', 1,1,0)
        return
    end
    
    membersInChannels = C_Club.GetClubMembers(communityID)

    --Only 4 invitations can be sent if you are not in raid mode
    --If no invitation is accepted in 1 minute, a new /invitetoraid would
    --need to be done
    InviteToRaid() --First invitation wave

    maxTime = 0
    checkParty()

end

SlashCmdList["COMMUNITY2RAID"] = InviteCommunity 
