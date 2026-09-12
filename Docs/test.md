> ```
> $connectionString = @"
> Server=sql2022;
> Database=TEST;
> User Id=sa;
> Password=Password123!;
> TrustServerCertificate=True;
> "@
>
> $query = @"
> SELECT *
> FROM dbo.MyTable
> "@
>
> $connection = [System.Data.SqlClient.SqlConnection]::new($connectionString)
>
> try {
>     $connection.Open()
>
>     $command = $connection.CreateCommand()
>     $command.CommandText = $query
>
>     $reader = $command.ExecuteReader()
>
>     while ($reader.Read()) {
>
>         # Column 0
>         $reader.GetValue(0)
>
>         # Column by name
>         $reader["CustomerName"]
>
>         # Entire row
>         for ($i = 0; $i -lt $reader.FieldCount; $i++) {
>             $reader.GetValue($i)
>         }
>     }
>
>     $reader.Close()
> }
> finally {
>     $connection.Close()
> }
> ```

Stream-Writer uses a lot of memory - building it into PS first is intensive - DataReader is a cursor and does not use memory on host side. No data is ever on host.
