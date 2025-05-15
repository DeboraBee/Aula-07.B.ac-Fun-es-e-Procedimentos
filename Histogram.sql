// Procedimento
CREATE PROCEDURE dbo.salaryHistogram
    @numBins INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @minSalary FLOAT, @maxSalary FLOAT, @range FLOAT;

    SELECT 
        @minSalary = MIN(salary),
        @maxSalary = MAX(salary)
    FROM instructor;

    IF @numBins <= 0 OR @minSalary IS NULL OR @maxSalary IS NULL OR @minSalary = @maxSalary
    BEGIN
        PRINT 'Não é possível calcular o histograma com os valores fornecidos.';
        RETURN;
    END

    SET @range = (@maxSalary - @minSalary) / @numBins;

    CREATE TABLE #Histogram (
        Intervalo VARCHAR(100),
        Frequencia INT
    );

    DECLARE @i INT = 0;
    WHILE @i < @numBins
    BEGIN
        DECLARE @lowerBound FLOAT = @minSalary + @i * @range;
        DECLARE @upperBound FLOAT = @lowerBound + @range;
        DECLARE @label VARCHAR(100) = 
            CONCAT(FORMAT(@lowerBound, 'N2'), ' - ', FORMAT(@upperBound, 'N2'));

        INSERT INTO #Histogram(Intervalo, Frequencia)
        SELECT 
            @label,
            COUNT(*) 
        FROM instructor
        WHERE salary >= @lowerBound AND 
              (salary < @upperBound OR (@i = @numBins - 1 AND salary <= @upperBound));

        SET @i += 1;
    END

    SELECT * FROM #Histogram;
    DROP TABLE #Histogram;
END;

//Execução
EXEC dbo.salaryHistogram 5;
