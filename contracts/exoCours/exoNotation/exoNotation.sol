// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract exoNotation is Ownable {

    enum course{Biology, Math, Fr}

    struct Student{
        string name;
        uint noteBiology;
        uint noteMath;
        uint noteFr;
    }

    mapping(course => mapping(string => Student)) notes;

    Student[] private students;
    mapping(course => address) teachers;

    event studentAdded(string _name, address _addr);
    event teacherAdded(course _course, address _addr);

    function addStudent(string calldata _name, address _addr) public onlyOwner{
        students.push(Student(_name, 0,0,0));
        emit studentAdded(_name, _addr);
    }

    function addTeacher(course _course, address _addr) public onlyOwner{
        teachers[_course] = _addr;
        emit teacherAdded(_course, _addr);
    }

    function getStudentFromName(string memory _name) private view returns(uint){
        for(uint i=0; i< students.length;i++){
            if(keccak256(abi.encodePacked(students[i].name)) == keccak256(abi.encodePacked(_name))){
                return i;
            }
        }
        return 0;
    }


    function addNote() public{

    }

    function getNote() public{
        
    }

    function setNote(course _course, string calldata _nameStudent, uint _note) public{
        
        uint idStudent = getStudentFromName(_nameStudent);
        require (msg.sender == teachers[_course], "You are not the teacher of this student course.");
        if(_course == course.Biology){
            students[idStudent].noteBiology = _note;
        }
        else if(_course == course.Fr){
            students[idStudent].noteFr = _note;
        }
        else if(_course == course.Math){
            students[idStudent].noteMath = _note;
        }
        else{
            revert("Course type does not exist.");
        }
    }
}