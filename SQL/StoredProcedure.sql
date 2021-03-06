
GO
/****** Object:  StoredProcedure [dbo].[SSP_RigMap]    Script Date: 5/19/2017 3:41:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 --SSP_RigMap 'Producing,Completion,Abandoned,Waiting on Completion,Licensed',null,null,null,'POLYGON((-117.6056819036603 54.226022005364456, -113.8428645208478 54.226022005364456, -113.8428645208478 56.04991230321732, -117.6056819036603 56.04991230321732, -117.6056819036603 54.226022005364456))'

 ALTER PROCEDURE [dbo].[SSP_RigMap] 

  @DrillStatus Varchar(200),

   @Type VARCHAR(50),

   @DateRange DATETIME =NULL,

   @ToDate    DATETIME =NULL,

   @MapBound  varchar(max),
    @ZoomLevel  varchar(30)

AS
  BEGIN
   
   DECLARE @envelope geometry

   set @envelope=geometry::STGeomFromText(@MapBound,0);

   Declare @3days Datetime= DateAdd(HOUR,-72,@DateRange)

   Declare @7days Datetime= DateAdd(day,-7,@DateRange)

   Declare @120days Datetime= DateAdd(dd,-120,getdate())

   Declare @45days Datetime= DateAdd(dd,-45,getdate())

   Declare @15days Datetime= DateAdd(dd,-25,getdate())


IF(@ZoomLevel=8 OR @ZoomLevel > 8)
BEGIN
 IF( @DateRange IS NULL )
				 SELECT  rig.rigid,
                   rig.rigname,
                   rig.supddate,
                   rig.releasedate,
                   rig.rignumber,
                   rig.rigtype,
                   rig.rigstatus,
                   rig.righistory,
                  -- rig.modifieddate,
				    CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
                   rig.description  AS RigDescription,
                   rig.wellname AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,
well.licensenumber,Well.Wellstatus
FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber

WHERE  well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE  IF( @Type = 'Today' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			   CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig
       JOIN well
         ON rig.licence = well.licensenumber
WHERE  --rig.rigstatus = @RigStatus

       (rig.createddate  >= @3days OR rig.ModifiedDate  >= @3days ) and (rig.createddate  <= @DateRange  OR rig.ModifiedDate  <= @DateRange) 

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1
ORDER  BY rig.createddate DESC

Else IF( @Type = 'SevenDays' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
            -- rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE  
       (rig.createddate  >= @7days OR rig.ModifiedDate  >= @7days) and (rig.createddate  <= @DateRange OR rig.ModifiedDate  <= @DateRange)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   --rig.rigstatus = @RigStatus
	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE IF( @Type = 'SelectDate' )
				SELECT  rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE 
       (rig.createddate >= @DateRange OR rig.modifieddate>= @DateRange)

	   AND (rig.createddate <= @ToDate OR rig.modifieddate >= @ToDate)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC
END


ELSE IF(@ZoomLevel=7)
BEGIN
IF( @DateRange IS NULL )
				 SELECT rig.rigid,
                   rig.rigname,
                   rig.supddate,
                   rig.releasedate,
                   rig.rignumber,
                   rig.rigtype,
                   rig.rigstatus,
                   rig.righistory,
                  -- rig.modifieddate,
				    CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
                   rig.description  AS RigDescription,
                   rig.wellname AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,
well.licensenumber,Well.Wellstatus
FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber

WHERE  well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1
	   --AND (rig.createddate  >= @120days OR rig.ModifiedDate  >= @120days ) and (rig.createddate  <= @120days  OR rig.ModifiedDate  <= @120days) 
	   AND (rig.createddate  >= @120days OR rig.ModifiedDate  >= @120days ) 

	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE  IF( @Type = 'Today' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			   CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig
       JOIN well
         ON rig.licence = well.licensenumber
WHERE  --rig.rigstatus = @RigStatus

       (rig.createddate  >= @3days OR rig.ModifiedDate  >= @3days ) and (rig.createddate  <= @DateRange  OR rig.ModifiedDate  <= @DateRange) 

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1
ORDER  BY rig.createddate DESC

Else IF( @Type = 'SevenDays' )
				 SELECT  rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
            -- rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE  
       (rig.createddate  >= @7days OR rig.ModifiedDate  >= @7days) and (rig.createddate  <= @DateRange OR rig.ModifiedDate  <= @DateRange)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   --rig.rigstatus = @RigStatus
	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE IF( @Type = 'SelectDate' )
				SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE 
       (rig.createddate >= @DateRange OR rig.modifieddate>= @DateRange)

	   AND (rig.createddate <= @ToDate OR rig.modifieddate >= @ToDate)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC
END


ELSE IF(@ZoomLevel=6)
BEGIN
IF( @DateRange IS NULL )
				 SELECT rig.rigid,
                   rig.rigname,
                   rig.supddate,
                   rig.releasedate,
                   rig.rignumber,
                   rig.rigtype,
                   rig.rigstatus,
                   rig.righistory,
                  -- rig.modifieddate,
				    CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
                   rig.description  AS RigDescription,
                   rig.wellname AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,
well.licensenumber,Well.Wellstatus
FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber

WHERE  well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
	  -- AND (rig.createddate  >= @45days OR rig.ModifiedDate  >= @45days ) and (rig.createddate  <= @45days  OR rig.ModifiedDate  <= @45days) 
	   AND (rig.createddate  >= @45days OR rig.ModifiedDate  >= @45days )
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE  IF( @Type = 'Today' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			   CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig
       JOIN well
         ON rig.licence = well.licensenumber
WHERE  --rig.rigstatus = @RigStatus

       (rig.createddate  >= @3days OR rig.ModifiedDate  >= @3days ) and (rig.createddate  <= @DateRange  OR rig.ModifiedDate  <= @DateRange) 

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1
ORDER  BY rig.createddate DESC

Else IF( @Type = 'SevenDays' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
            -- rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE  
       (rig.createddate  >= @7days OR rig.ModifiedDate  >= @7days) and (rig.createddate  <= @DateRange OR rig.ModifiedDate  <= @DateRange)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   --rig.rigstatus = @RigStatus
	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE IF( @Type = 'SelectDate' )
				SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE 
       (rig.createddate >= @DateRange OR rig.modifieddate>= @DateRange)

	   AND (rig.createddate <= @ToDate OR rig.modifieddate >= @ToDate)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC
END

ELSE
BEGIN
IF( @DateRange IS NULL )
				 SELECT  rig.rigid,
                   rig.rigname,
                   rig.supddate,
                   rig.releasedate,
                   rig.rignumber,
                   rig.rigtype,
                   rig.rigstatus,
                   rig.righistory,
                  -- rig.modifieddate,
				    CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
                   rig.description  AS RigDescription,
                   rig.wellname AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,
well.licensenumber,Well.Wellstatus
FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber

WHERE  well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1

	   --AND (rig.createddate  >= @15days OR rig.ModifiedDate  >= @15days ) and (rig.createddate  <= @15days  OR rig.ModifiedDate  <= @15days) 
	   AND (rig.createddate  >= @15days OR rig.ModifiedDate  >= @15days )
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE  IF( @Type = 'Today' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			   CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig
       JOIN well
         ON rig.licence = well.licensenumber
WHERE  --rig.rigstatus = @RigStatus

       (rig.createddate  >= @3days OR rig.ModifiedDate  >= @3days ) and (rig.createddate  <= @DateRange  OR rig.ModifiedDate  <= @DateRange) 

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))

       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1
ORDER  BY rig.createddate DESC

Else IF( @Type = 'SevenDays' )
				 SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
            -- rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE  
       (rig.createddate  >= @7days OR rig.ModifiedDate  >= @7days) and (rig.createddate  <= @DateRange OR rig.ModifiedDate  <= @DateRange)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   --rig.rigstatus = @RigStatus
	    And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC

ELSE IF( @Type = 'SelectDate' )
				SELECT rig.rigid,
             rig.rigname,
             rig.supddate,
             rig.releasedate,
             rig.rigtype,
             rig.rignumber,
             rig.rigstatus,
             rig.righistory,
             --rig.modifieddate,
			  CONVERT(VARCHAR,rig.modifieddate,101) AS modifieddate,
             rig.description                 AS RigDescription,
             rig.wellname                    AS RigWellName,

well.wellname,
well.dls,
well.uwi,
well.wellid,
well.latitude,
well.longitude,Well.Wellstatus,
well.licensenumber

FROM   rig

       JOIN well

         ON rig.licence = well.licensenumber
WHERE 
       (rig.createddate >= @DateRange OR rig.modifieddate>= @DateRange)

	   AND (rig.createddate <= @ToDate OR rig.modifieddate >= @ToDate)

       AND well.dls IS NOT NULL

       AND rig.isdeleted = 0 

	   And well.WellStatus in(select Value from [dbo].f_IntSplit_string(@DrillStatus,','))
       AND rig.isactive = 1
	   AND geometry::Parse('POINT('+well.Longitude+'  '+well.latitude+')').STIntersects(@MapBound)=1

ORDER  BY rig.createddate DESC
END
END