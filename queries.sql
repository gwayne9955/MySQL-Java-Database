with LengthOfStay as 
    (select Room, max(CheckIn) CI, max(CheckOut) RecentCO, DATEDIFF(max(CheckOut), max(CheckIn)) LengthPrev
        from lab7_reservations
        where CheckIn <= CURDATE()
        group by room
        order by LengthPrev desc, RecentCO)
    , NextDay as 
    (select Room, 
        (case when min(CheckIn) < CURDATE() then min(CheckOut)
        else CURDATE()
        end) NextAvailable
        from lab7_reservations 
        where CheckOut >= CURDATE() 
        group by Room
        order by NextAvailable) 
    , RoomPopularity as 
    (select rm.RoomCode Room, 
        round(sum(
            (case when datediff(CURDATE(), rv.Checkout) <= 180 and datediff(CURDATE(), rv.Checkout) >= 0
                then datediff(rv.Checkout, rv.Checkin) 
                else 0 
            end) - 
            (case when datediff(CURDATE(), rv.Checkin) > 180 and datediff(CURDATE(), rv.Checkout) <= 180
                then datediff(CURDATE(), rv.Checkin) - 180
                else 0
            end)) / 180, 2) Popularity 
        from lab7_rooms rm join lab7_reservations rv on rm.RoomCode = rv.Room
        group by rm.RoomCode
        order by Popularity)
    select NextDay.Room, Popularity, NextAvailable, LengthPrev, RecentCO from RoomPopularity
        inner join NextDay on RoomPopularity.Room=NextDay.Room
        inner join LengthOfStay on LengthOfStay.Room=NextDay.Room
        order by Popularity desc, NextAvailable, LengthPrev desc, RecentCO
                         
