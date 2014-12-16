function collect(start_pos,s)
    local result = "";
    local bracketL = 0;
    local bracketR = 0;
    local i = start_pos;
    while (1) do
        if s:sub(i,i) == "{" then bracketL = bracketL + 1; end
        if s:sub(i,i) == "}" then bracketR = bracketR + 1; end
        if (bracketL == bracketR) and (bracketL > 0) then
--            collect = collect..db:sub(start_pos,i+1); -- i+1 для захвата точки с запятой.
            break;
        end
        i = i + 1;
    end
    result = s:sub(start_pos,i+1);
    --if result:find("player=\"PLAY CDG\";") then return result; end
    if result:find("player=") then return result; end -- collecting class contained only playable unit
end

function parse(item,side,ng)
    local id = item:match("id=(%d+)");
    local vehicle = item:match("vehicle=\"(%g*)\"");
    table.insert(groups[side][ng], {id, vehicle});
end

function items(i,side) -- extract each item class from found vehicle class with playeable unit.
    -- i - input data base (class Item)
    -- side - group side

    table.insert(groups[side],{}); -- create new group side
    local ng = table.maxn(groups[side]); -- current number group side
        
    local s = 1;
    local e = 1;
    local item;
    while (e) do
    
        s,e = string.find(i,"class Item",s+1); --find start and end position for next item class of vehicle class
        item = s and collect(s,i); --extract item class if we have start position
        if (item) then
            print("\n\n-----------------------------------",side);
            --print(s,e);
            print(item);
            parse(item,side,ng);
        end
    end
end


-- ############################################################## --
f = io.open("mission.sqm","r");
db = f:read("*a");
f:close();
s,e = string.find(db,"class Groups");
--print(s,e);
groups = {};
groups.east = {};
groups.west = {};
groups.guer = {};
groups.civ = {};


db = collect(s,db); --extract class Groups

s = 1; -- start position for search
while (e) do

    local gr,side;
    s,e = string.find(db,"class Vehicles",s+1); --find start and end position for next vehicle class of groups class
    gr = s and collect(s,db); --extract vehicles class if we have start position
    if (gr) then
        if (string.find(gr,"side=\"EAST\";")) then
            side = "east";
        elseif (string.find(gr,"side=\"WEST\";")) then
            side = "west";
        elseif (string.find(gr,"side=\"CIV\";")) then
            side = "civ";
        elseif (string.find(gr,"side=\"GUER\";")) then
            side = "guer";
        end
        --print("-----------------------------------");
        --print(gr);
        items(gr,side);
    end
end

print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");

for k,v in pairs(groups) do
    print(table.maxn(groups[k]),k);
end
    
print("\nfor example output 'id' and 'vehicle' for 4 group east side")
for k,v in pairs(groups.east[4]) do
    print(k,v[1],v[2]);
end

