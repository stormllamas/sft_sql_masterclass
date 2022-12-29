WITH employee_hierarchy AS (
	SELECT e.StaffId AS EmployeeId
		, e.FirstName + ' ' + e.LastName AS FullName
		, CAST(e.FirstName + ' ' + e.LastName + ', ' 
			AS VARCHAR(500)) AS EmployeeHierarchy
	FROM Staff e
	WHERE ManagerId IS NULL -- ANCHOR

	UNION ALL

	SELECT e.StaffId AS EmployeeId
		, e.FirstName + ' ' + e.LastName AS FullName
		, CAST(eh.EmployeeHierarchy 
				+ e.FirstName 
				+ ' ' + e.LastName 
				+ ', ' AS VARCHAR(500))
	FROM Staff e
	INNER JOIN employee_hierarchy AS eh
		ON (e.ManagerId = eh.EmployeeId)

)

SELECT eh.EmployeeId
	, eh.FullName
	, eh.EmployeeHierarchy
FROM employee_hierarchy eh
ORDER BY eh.EmployeeId
OPTION (MAXRECURSION 150)