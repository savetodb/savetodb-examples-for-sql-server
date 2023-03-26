-- =============================================
-- Application: Sample 06 - Dynamic Lists
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
--
-- Prerequisites: SaveToDB Framework 8.19 or higher
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s06;
GO

CREATE TABLE s06.countries (
    id int IDENTITY(1,1) NOT NULL
    , country nvarchar(100) NOT NULL
    , CONSTRAINT PK_countries PRIMARY KEY (id)
    , CONSTRAINT IX_countries UNIQUE (country)
);
GO

CREATE TABLE s06.states (
    code char(2) NOT NULL
    , country_id int NOT NULL
    , state nvarchar(50) NOT NULL
    , capital nvarchar(50) NULL
    , CONSTRAINT PK_states PRIMARY KEY (code)
    , CONSTRAINT IX_states UNIQUE (state)
);
GO

ALTER TABLE s06.states ADD CONSTRAINT FK_states_countries FOREIGN KEY (country_id) REFERENCES s06.countries (id);
GO

CREATE TABLE s06.data (
    id int IDENTITY(1,1) NOT NULL
    , country_id int NULL
    , state_code char(2) NULL
    , period date NULL
    , value float NULL
    , CONSTRAINT PK_data PRIMARY KEY (id)
);
GO

ALTER TABLE s06.data ADD CONSTRAINT FK_data_countries FOREIGN KEY (country_id) REFERENCES s06.countries (id);
GO

ALTER TABLE s06.data ADD CONSTRAINT FK_data_states FOREIGN KEY (state_code) REFERENCES s06.states (code);
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure shows using parameters and dynamic validation lists
-- =============================================

CREATE PROCEDURE [s06].[usp_data]
    @country_id int = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    d.id
    , d.state_code
    , d.period
    , d.value
FROM
    s06.data d
WHERE
    d.country_id = @country_id

END


GO

SET IDENTITY_INSERT s06.countries ON;
INSERT INTO s06.countries (id, country) VALUES (1, N'USA');
INSERT INTO s06.countries (id, country) VALUES (2, N'Canada');
SET IDENTITY_INSERT s06.countries OFF;
GO

INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'AK', 1, N'Alaska', N'Juneau');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'AL', 1, N'Alabama', N'Montgomery');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'AR', 1, N'Arkansas', N'Little Rock');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'AZ', 1, N'Arizona', N'Phoenix');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'CA', 1, N'California', N'Sacramento');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'CO', 1, N'Colorado', N'Denver');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'CT', 1, N'Connecticut', N'Hartford');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'DE', 1, N'Delaware', N'Dover');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'FL', 1, N'Florida', N'Tallahassee');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'GA', 1, N'Georgia', N'Atlanta');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'HI', 1, N'Hawaii', N'Honolulu');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'IA', 1, N'Iowa', N'Des Moines');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'ID', 1, N'Idaho', N'Boise');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'IL', 1, N'Illinois', N'Springfield');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'IN', 1, N'Indiana', N'Indianapolis');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'KS', 1, N'Kansas', N'Topeka');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'KY', 1, N'Kentucky', N'Frankfort');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'LA', 1, N'Louisiana', N'Baton Rouge');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MA', 1, N'Massachusetts', N'Boston');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MD', 1, N'Maryland', N'Annapolis');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'ME', 1, N'Maine', N'Augusta');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MI', 1, N'Michigan', N'Lansing');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MN', 1, N'Minnesota', N'Saint Paul');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MO', 1, N'Missouri', N'Jefferson City');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MS', 1, N'Mississippi', N'Jackson');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MT', 1, N'Montana', N'Helena');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NC', 1, N'North Carolina', N'Raleigh');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'ND', 1, N'North Dakota', N'Bismarck');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NE', 1, N'Nebraska', N'Lincoln');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NH', 1, N'New Hampshire', N'Concord');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NJ', 1, N'New Jersey', N'Trenton');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NM', 1, N'New Mexico', N'Santa Fe');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NV', 1, N'Nevada', N'Carson City');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NY', 1, N'New York', N'Albany');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'OH', 1, N'Ohio', N'Columbus');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'OK', 1, N'Oklahoma', N'Oklahoma City');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'OR', 1, N'Oregon', N'Salem');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'PA', 1, N'Pennsylvania', N'Harrisburg');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'RI', 1, N'Rhode Island', N'Providence');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'SC', 1, N'South Carolina', N'Columbia');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'SD', 1, N'South Dakota', N'Pierre');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'TN', 1, N'Tennessee', N'Nashville');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'TX', 1, N'Texas', N'Austin');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'UT', 1, N'Utah', N'Salt Lake City');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'VA', 1, N'Virginia', N'Richmond');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'VT', 1, N'Vermont', N'Montpelier');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'WA', 1, N'Washington', N'Olympia');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'WI', 1, N'Wisconsin', N'Madison');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'WV', 1, N'West Virginia', N'Charleston');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'WY', 1, N'Wyoming', N'Cheyenne');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'AB', 2, N'Alberta', N'Edmonton');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'BC', 2, N'British Columbia', N'Victoria');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'MB', 2, N'Manitoba', N'Winnipeg');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NB', 2, N'New Brunswick', N'Fredericton');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NL', 2, N'Newfoundland and Labrador', N'St. John''s');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NS', 2, N'Nova Scotia', N'Halifax');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NT', 2, N'Northwest Territories', N'Yellowknife');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'NU', 2, N'Nunavut', N'Iqaluit');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'ON', 2, N'Ontario', N'Toronto');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'PE', 2, N'Prince Edward Island', N'Charlottetown');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'QC', 2, N'Quebec', N'Quebec City');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'SK', 2, N'Saskatchewan', N'Regina');
INSERT INTO s06.states (code, country_id, state, capital) VALUES (N'YT', 2, N'Yukon', N'Whitehorse');
GO

SET IDENTITY_INSERT s06.data ON;
INSERT INTO s06.data (id, country_id, state_code, period, value) VALUES (1, 1, N'AK', '20230331', 100);
INSERT INTO s06.data (id, country_id, state_code, period, value) VALUES (2, 2, N'AB', '20230331', 100);
SET IDENTITY_INSERT s06.data OFF;
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's06', N'countries', N'<table name="s06.countries"><columnFormats><column name="" property="ListObjectName" value="countries" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="country" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="country" property="Address" value="$D$4" type="String" /><column name="country" property="ColumnWidth" value="16.43" type="Double" /><column name="country" property="NumberFormat" value="General" type="String" /><column name="country" property="Validation.Type" value="6" type="Double" /><column name="country" property="Validation.Operator" value="8" type="Double" /><column name="country" property="Validation.Formula1" value="100" type="String" /><column name="country" property="Validation.AlertStyle" value="1" type="Double" /><column name="country" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="country" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="country" property="Validation.ShowInput" value="True" type="Boolean" /><column name="country" property="Validation.ShowError" value="True" type="Boolean" /><column name="SortFields(1)" property="KeyfieldName" value="id" type="String" /><column name="SortFields(1)" property="SortOn" value="0" type="Double" /><column name="SortFields(1)" property="Order" value="1" type="Double" /><column name="SortFields(1)" property="DataOption" value="0" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's06', N'data', N'<table name="s06.data"><columnFormats><column name="" property="ListObjectName" value="data" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="country_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="country_id" property="Address" value="$D$4" type="String" /><column name="country_id" property="ColumnWidth" value="12.14" type="Double" /><column name="country_id" property="NumberFormat" value="General" type="String" /><column name="country_id" property="Validation.Type" value="3" type="Double" /><column name="country_id" property="Validation.Operator" value="1" type="Double" /><column name="country_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s06_countries_id_country[country]&quot;)" type="String" /><column name="country_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="country_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="country_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="country_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="country_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="state_code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="state_code" property="Address" value="$E$4" type="String" /><column name="state_code" property="ColumnWidth" value="26" type="Double" /><column name="state_code" property="NumberFormat" value="General" type="String" /><column name="state_code" property="Validation.Type" value="3" type="Double" /><column name="state_code" property="Validation.Operator" value="1" type="Double" /><column name="state_code" property="Validation.Formula1" value="=vl_d1_data" type="String" /><column name="state_code" property="Validation.AlertStyle" value="1" type="Double" /><column name="state_code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="state_code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="state_code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="state_code" property="Validation.ShowError" value="True" type="Boolean" /><column name="period" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="period" property="Address" value="$F$4" type="String" /><column name="period" property="ColumnWidth" value="16.43" type="Double" /><column name="period" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="period" property="Validation.Type" value="4" type="Double" /><column name="period" property="Validation.Operator" value="5" type="Double" /><column name="period" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="period" property="Validation.AlertStyle" value="1" type="Double" /><column name="period" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="period" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="period" property="Validation.ShowInput" value="True" type="Boolean" /><column name="period" property="Validation.ShowError" value="True" type="Boolean" /><column name="value" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="value" property="Address" value="$G$4" type="String" /><column name="value" property="ColumnWidth" value="10" type="Double" /><column name="value" property="NumberFormat" value="General" type="String" /><column name="value" property="Validation.Type" value="2" type="Double" /><column name="value" property="Validation.Operator" value="4" type="Double" /><column name="value" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="value" property="Validation.AlertStyle" value="1" type="Double" /><column name="value" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="value" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="value" property="Validation.ShowInput" value="True" type="Boolean" /><column name="value" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's06', N'states', N'<table name="s06.states"><columnFormats><column name="" property="ListObjectName" value="states" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$C$4" type="String" /><column name="code" property="ColumnWidth" value="6" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="2" type="String" /><column name="code" property="Validation.AlertStyle" value="1" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="code" property="Validation.ErrorMessage" value="The column requires values of the char(2) datatype." type="String" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="country_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="country_id" property="Address" value="$D$4" type="String" /><column name="country_id" property="ColumnWidth" value="12" type="Double" /><column name="country_id" property="NumberFormat" value="General" type="String" /><column name="country_id" property="Validation.Type" value="3" type="Double" /><column name="country_id" property="Validation.Operator" value="1" type="Double" /><column name="country_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s06_countries_id_country[country]&quot;)" type="String" /><column name="country_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="country_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="country_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="country_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="country_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="state" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="state" property="Address" value="$E$4" type="String" /><column name="state" property="ColumnWidth" value="26" type="Double" /><column name="state" property="NumberFormat" value="General" type="String" /><column name="state" property="Validation.Type" value="6" type="Double" /><column name="state" property="Validation.Operator" value="8" type="Double" /><column name="state" property="Validation.Formula1" value="50" type="String" /><column name="state" property="Validation.AlertStyle" value="1" type="Double" /><column name="state" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="state" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="state" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="state" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="state" property="Validation.ShowInput" value="True" type="Boolean" /><column name="state" property="Validation.ShowError" value="True" type="Boolean" /><column name="capital" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="capital" property="Address" value="$F$4" type="String" /><column name="capital" property="ColumnWidth" value="13.29" type="Double" /><column name="capital" property="NumberFormat" value="General" type="String" /><column name="capital" property="Validation.Type" value="6" type="Double" /><column name="capital" property="Validation.Operator" value="8" type="Double" /><column name="capital" property="Validation.Formula1" value="50" type="String" /><column name="capital" property="Validation.AlertStyle" value="1" type="Double" /><column name="capital" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="capital" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="capital" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="capital" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="capital" property="Validation.ShowInput" value="True" type="Boolean" /><column name="capital" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="FormatConditions(1).ColumnsCount" value="3" type="Double" /><column name="code" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$E$53" type="String" /><column name="code" property="FormatConditions(1).Type" value="2" type="Double" /><column name="code" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="code" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String" /><column name="code" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="code" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's06', N'usp_data', N'country_id', N'ParameterValues', N's06', N'countries', N'TABLE', N'[id],[country]', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's06', N'data', N'country_id', N'ValidationList', N's06', N'countries', N'TABLE', N'[id],[country]', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's06', N'data', N'state_code', N'ValidationList', N's06', N'states', N'TABLE', N'[code],[state],[country_id]', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's06', N'usp_data', N'state_code', N'ValidationList', N's06', N'states', N'TABLE', N'[code],[state],@country_id', NULL, NULL, NULL);
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 06 - Dynamic Lists.xlsx', N'Sample 06 - Dynamic Lists.xlsx', N'countries=s06.countries,xls.queries,False,$B$3,,{"Parameters":{},"ListObjectName":"countries"}
states=s06.states,xls.queries,False,$B$3,,{"Parameters":{"country_id":1},"ListObjectName":"states"}
data=s06.data,xls.queries,False,$B$3,,{"Parameters":{},"ListObjectName":"data"}
handlers=xls.handlers,xls,False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s06"},"ListObjectName":"handlers"}', N's06');
GO

print 'Application installed';
