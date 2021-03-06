
GO
/****** Object:  StoredProcedure [dbo].[InsertIndividualToPerson]    Script Date: 11/9/2016 2:22:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertIndividualToPerson]') AND TYPE IN (N'P', N'PC'))
BEGIN
		EXEC ('CREATE PROCEDURE [dbo].[InsertIndividualToPerson]
		AS
		BEGIN
			SELECT 1
		END')
END
GO

ALTER PROCEDURE [dbo].[InsertIndividualToPerson] 
( 
@UserGedComFileID INT,
@TransactionStatus INT OUTPUT,
@TransactionMessage VARCHAR(MAX) OUTPUT,
@FileName VARCHAR(1000) OUTPUT,
@UserName VARCHAR(200) OUTPUT,
@Email VARCHAR(200) OUTPUT
)
AS
     BEGIN
         SET NOCOUNT ON;
         BEGIN TRANSACTION Trans;
         BEGIN TRY
             DECLARE @UserId INT; 
             --  declare @UserGedComFileId int   
             SELECT TOP 1 @UserId = Createdby
               FROM [PeopleArchive].[dbo].[Individuals] WITH
                                                             ( NOLOCK
                                                             )
               WHERE [IsArchived] = 0
                     AND [IsDeleted] = 0
                     AND UserGedComFileID = @UserGedComFileID;


             --   DECLARE @ManagerIdTable TABLE( managerid INT );
             DECLARE @ManagerId INT;
             IF EXISTS
                      (
                        SELECT COUNT( 1 )
                          FROM Managers WITH
                                             ( NOLOCK
                                             )
                          WHERE userid = @UserId
                                AND IsActive = 1
                      )
                 BEGIN
                     SET @ManagerId =
                                      (
                                        SELECT TOP 1 ManagerId
                                          FROM [PeopleArchive].[dbo].[Managers] WITH
                                                                                     ( NOLOCK
                                                                                     )
                                          WHERE userid = @UserId
                                                AND IsActive = 1
                                      );
                 END;
             ELSE
                 BEGIN
                     INSERT INTO [PeopleArchive].[dbo].[Managers]
                                                                 ( UserId,
                                                                   DateAdded,
                                                                   IsActive,
                                                                   SuperAdminId
                                                                 )
                     --   OUTPUT INSERTED.managerid
                     --        INTO @ManagerIdTable
                     VALUES
                           ( @UserId,GETDATE( ),1,NULL
                           );
                     SET @ManagerId = SCOPE_IDENTITY( );
                 END;
             DECLARE @InsertedPersonIds TABLE( PersonIds INT,IndividualIds INT );
             INSERT INTO PEOPLEARCHIVE..PERSONS
                                               ( [FirstName],
                                                 [MiddleName],
                                                 [LastName],
                                                 [DateOfBirth],
                                                 [DateOfDeath],
                                                 [LivingStatusId],
                                                 [BirthPlace],
                                                 [DeathPlace],
                                                 [CreatedBy],
                                                 [DateAdded],
                                                 ChildStatus,
                                                 IndividualsId
                                               )
             OUTPUT INSERTED.PersonId,
                    INSERTED.IndividualsId
                    INTO @insertedpersonids
                    SELECT [FirstName],
                           [MiddleName],
                           [LastName],
                           [BirthDate],
                           [DeathDate],
                           CASE
                           WHEN [Deceased] IS NULL THEN 3
                           WHEN [Deceased] = 0 THEN 2
                               ELSE 1
                           END AS [LivingStatusId],
                           [BirthPlace],
                           [DeathPlace],
                           [CreatedBy],
                           GETDATE( ) DateAdded,
                           0 AS ChildStatus,
                           [Id]
                      FROM [PeopleArchive].[dbo].[Individuals] WITH(NOLOCK)
                      WHERE [IsArchived] = 0
                            AND [IsDeleted] = 0
                            AND UserGedComFileID = @UserGedComFileId;
             INSERT INTO [PeopleArchive].[dbo].[PersonManagers]
                                                               ( PersonId,
                                                                 ManagerId,
                                                                 DateAdded,
                                                                 IsActive
                                                               )
                    SELECT PersonIds,
                           @ManagerId,
                           GETDATE( ),
                           1
                      FROM @InsertedPersonIds;
             UPDATE [PeopleArchive].[dbo].[Individuals]
               SET
                   IsArchived = 1
               WHERE UserGedComFileID = @UserGedComFileId;
             SELECT *
               FROM @InsertedPersonIds;
             INSERT INTO [PeopleArchive].[dbo].[PersonDetail]( 
													 [PersonId],
                                                                  [RelationshipTypeId],
                                                                  [RelatedWithPersonId],
                                                                  [CreatedDate],
                                                                  [CreatedBy],
                                                                  [IsDeleted]
                                                                )
                    SELECT
                          (
                            SELECT personId
                              FROM [PeopleArchive].[dbo].[persons] WITH(NOLOCK)
                              WHERE individualsid = V.IndividualID
                          ) AS PersonId,
                          V.RelationshipTypeId,
                          (
                            SELECT personId
                              FROM [PeopleArchive].[dbo].[persons] WITH(NOLOCK)
                              WHERE individualsid = I.Id
                          ) AS RelatedWithPersonId,
                          GETDATE( ) AS CreatedDate,
                          V.CreatedBy AS CreatedBy,
                          0 AS IsDeleted
                      FROM [PeopleArchive].[dbo].[Individuals] I WITH(NOLOCK)
                           INNER JOIN [PeopleArchive].[dbo].[IndividualRelationShipsV1] V WITH(NOLOCK) ON V.RelationWithID = I.EntityId
                                                                                                    AND V.IsDeleted = 0
                      WHERE I.UserGedComFileID = @UserGedComFileId
                            AND I.IsDeleted = 0
                            AND V.IndividualID IN
                                                 (
                                                   SELECT IndividualIds
                                                     FROM @InsertedPersonIds
                                                 );

         

             SELECT TOP 1 @FileName = UGF.[FileName],
                          @UserName = U.[FirstName]+' '+U.[LastName],
                          @Email = U.[EmailAddress]
               FROM [dbo].[UserGedcomFiles] UGF WITH(NOLOCK)
                    INNER JOIN [siteinfo].[dbo].[Users] U WITH (NOLOCK) ON U.UserId = UGF.CreatedBy
               WHERE U.UserId = @UserId
                     AND UGF.Id = @UserGedComFileID;
             SET @TransactionStatus = 0;
             SET @TransactionMessage = 'Successful Transaction';
             COMMIT TRANSACTION Trans;
         END TRY
         BEGIN CATCH
             DECLARE @ErrorMessage NVARCHAR(4000);
             DECLARE @ErrorSeverity INT;
             DECLARE @ErrorState INT;
             SET @TransactionStatus = 1;
             SET @TransactionMessage = ERROR_MESSAGE( );
             ROLLBACK TRANSACTION Trans;
             SELECT @ErrorMessage = ERROR_MESSAGE( ),
                    @ErrorSeverity = ERROR_SEVERITY( ),
                    @ErrorState = ERROR_STATE( );
				set @FileName='Error'
          
         END CATCH;
     END;


 GO
