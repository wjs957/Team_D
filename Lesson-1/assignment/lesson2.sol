/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract PayRoll{
    struct Employee{
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    address owner;
    uint payDurtion = 10 seconds;
    Employee[] employees;
    
    uint totaSalary;
    
    function PayRoll(){
        
        owner = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
        
    }
    
    function _partialPaid(Employee employee) private{
        uint payment = employee.salary * (now - employee.lastPayDay)/payDurtion;
        employee.id.transfer(payment);   
    }
    function _findEmployee(address employeeId) private returns (Employee,uint){
         for(uint i=0;i<employees.length;i++){
              if(employees[i].id==employeeId){
                  return (employees[i],i);
              }
         }
    }
    function addEmployee(address employeeId ,uint salary){
        require(msg.sender==owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        uint userSalary = salary * 1 ether;
        employees.push(Employee(employeeId,userSalary,now));
        totaSalary+=userSalary;
        
    }
    function removeEmployee(address employeeId){
        require(msg.sender==owner);
        
        assert(employees.length>0);
        
        var (employee, index) = _findEmployee(employeeId);
        
        assert(employee.id != 0x0);
        
        _partialPaid(employee);
        delete employees[index];
        if(employees.length>1){
            employees[index]=employees[employees.length-1];    
        }
    
        employees.length-=1;
        totaSalary-=employee.salary;
    }
    function updateEmployee(address employeeId,uint salary) {
        require(msg.sender==owner && employees.length>0);
        
        // assert(employees.length>0);
        
        var (employee, index) = _findEmployee(employeeId);
    
        assert(employee.id!= 0x0 && employee.salary != salary);
        
        _partialPaid(employee);
        totaSalary -= (employee.salary-salary);
        employees[index].salary = salary;
        employees[index].lastPayDay=now;
    }
    
    function addFund() payable returns (uint){
        
        return this.balance;
    }
    
    function calculteRunway() returns (uint){
        require(msg.sender==owner);
        //uint totaSalary;
        // for(uint i=0;i<employees.length;i++){
        //     totaSalary += employees[i].salary;
        // }
        
        return  this.balance / totaSalary;
    }
    
    function hasEnoughFund() returns (bool){
        require(msg.sender==owner);
        return calculteRunway()>0;
    }
    
    function getPaid(){
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayDay = employee.lastPayDay + payDurtion;
        
        assert(nextPayDay < now);
        
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
        
    }

}
