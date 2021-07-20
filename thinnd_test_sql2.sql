create database ThinND_0951
go
use ThinND_0951
create table EmployeeType
( EmpTypeId int primary key identity not null ,
EmpTypeName nvarchar(50),
Status bit 
)
go
create table Department
(
DepartmentId int primary key identity not null ,
DepartmentName nvarchar(50),
Location nvarchar(50),
Status bit 
)
go
create table Employee
(
 EmpId nvarchar(50) primary key not null,
EmpName nvarchar(50),
HireDate date, 
Salary float,
Email nvarchar(50),
Phone nvarchar(50),
Sex bit ,
Status bit ,
DepartmentId int not null,
EmpTypeId int not null
)
go

--3. Tạo rằng buộc giữa bảng Employee và các bảng khác(1)ALTER TABLE Employee
ADD CONSTRAINT fk_htk_DepartmentId
 FOREIGN KEY (DepartmentId)
 REFERENCES Department (DepartmentId);
 -------------------
 ALTER TABLE Employee
ADD CONSTRAINT fk_htk_EmpTypeId
 FOREIGN KEY (EmpTypeId)
 REFERENCES EmployeeType (EmpTypeId);
 --4. Thêm dữ liệu vào bảng(2)
 insert into dbo.EmployeeType values
 (N'Nhân viên cơ hữu',1),
 (N'Nhân viên cộng tác',1),
 (N'Nhân viên fulltime',0)
-----------------
insert into dbo.Department values
(N'Phòng CMLT',304,1),
(N'Phòng CMM',306,1),
(N'Phòng đào tạo',301,1)
-----------------
insert into dbo.Employee values
(N'E011','Nguyễn Công Phượng','2017/05/14',10000000,'phuongnc@gmail.com',0948385837,1,1,1,1)
insert into dbo.Employee values
(N'E012','Nguyễn Trung Hiếu','2014/06/08',800000,'hieunt@gmail.com',0904488485,1,1,2,2),
(N'E013','Nguyễn Thị Thủy','2013/09/06',90000,'thuynt@gmail.com',0904305253,0,1,3,3),
(N'E014','Nguyễn Thị Thắm','2016/08/05',650000,'thamnt@gmail.com',0949904567,0,1,2,1),
(N'E015','Lê Thanh Thúy','2012/02/01',750000,'thuylt@gmail.com',0948856932,0,0,1,3)
go
--5. Hiển thị thông tin theo kết quả sau(2)
select 
e.EmpId as [MaNV] , 
e.EmpName as [TenNV],
e.Sex as [GioiTinh],
e.Salary as [Luong],
d.DepartmentName as [TenPhong] 
from Employee as e ,Department as d
where e.DepartmentId = d.DepartmentId
----------
SELECT *
FROM Employee
WHERE Employee.EmpName LIKE '%g';
-------
select e.EmpId , e.EmpName,d.DepartmentId,d.DepartmentName
from Employee e , Department d
where e.DepartmentId=d.DepartmentId

---------
--6. Cập nhật nhân viên có trạng thái là false thành nhân viên có trạng thái là null(2)
UPDATE Employee
SET Status=null
WHERE Status=0;
--7. Xóa nhân viên có trạng thái là null(2)
delete from Employee
where Status = Null
----8.Tạo chỉ mục cho (Index) trên cột EmpName của bảng Employee(2)
CREATE INDEX id_empName
ON Employee (EmpName);
--9. Tạo View có tên vwEmployee có thông tin như hình sau(2)create VIEW vwEmployee
as
select
e.EmpName as [Ten Nhan Vien], 
d.DepartmentName as [Ten Phong Ban],
d.Location as [Noi lam viec], 
et.EmpTypeName as [Loai Nhan Vien]
from
Employee e ,Department d , EmployeeType et
where e.DepartmentId=d.DepartmentId
and
e.EmpTypeId=et.EmpTypeId 

select * from vwEmployee
--10.Tạo các thủ tục sau(2)
create procedure pr_cau1
as
begin
declare @x float ,@y float
set @x=1 ;
set @y=10000000;
select * from Employee
where Salary>@x and Salary<@y
end
exec pr_cau1
------------------------
create procedure pr_cau2
(
@EmpId nvarchar(50) ,
@EmplName nvarchar(50),
@HireDate date,
@Salary float,
@Email nvarchar(50),
@Phone nvarchar(50),
@Sex bit,
@Status bit ,
@DepartmentId int,
@EmpTypeId int
)
as
begin
update [dbo].[Employee]
set 
[EmpId]=@EmpId,
[EmpName]=@EmplName,
[HireDate]=@HireDate,
[Salary]=@Salary,
[Email]=@Email,
[Phone]=@Phone,
[Sex]=@Sex,
[Status]=@Status,
[DepartmentId]=@DepartmentId,
[EmpTypeId]=@EmpTypeId
where @HireDate>GETDATE()
if(@HireDate>GETDATE())
begin 
print 'HireDate lon hon ngay hien tai'
end
else 
begin
print 'Cap nhat thanh cong'
end
end
---------------------
create PROCEDURE pr_cau3
as
begin
select 
e.EmpId ,e.EmpName ,e.HireDate,e.Salary,e.Email,e.Phone,e.Sex,e.Status,e.DepartmentId,e.EmpTypeId
from Employee as e
where e.Salary > 7000000
end

exec pr_cau3

--11.Tạo các Trigger sau: (2)create Trigger tg_cau1
On dbo.Employee 
For Insert
As
 If (Select Count(a.HireDate)
     From Employee a Inner Join INSERTED b On a.HireDate = b.HireDate) > GETDATE()
 Begin
   Print 'Khong duoc lon hon ngay hien tai'
   RollBack Tran
 End-------------------create Trigger tg_cau2 
On dbo.Department
For Update 
As
Declare @D int
Select @D = Count(*)
From Department a, DELETED b, INSERTED c
Where a.DepartmentId = b.DepartmentId
      And a.DepartmentId = c.DepartmentId 
      And a.DepartmentName = 'Phòng CMML'
If (@D > 0 )
 Begin
   Print 'Không cho phép cập nhật thông tin của các phòng ban'
   RollBack Tran
   Return
 End------------------create trigger tg_cau3on dbo.EmployeeTypefor deleteasbegindeclare @count int = 0select @count=COUNT(*) from deletedwhere status =1 if(@count>0)beginprint 'Khong duoc xoa nguoi co trang thai = 1'endenddelete from EmployeeType where Status=1