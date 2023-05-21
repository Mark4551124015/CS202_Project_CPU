# CS202_Project_CPU

## Group Member

LIU Xiaoqun (12110943), GOU Yebei (12111427), FENG Zexin(12110104)

## File Structure

```tex
📂CS202_Project_CPU
 ┣ 📂project 	//项目文件
 ┣ 📂config		//配置文件
 ┣ 📂doc		//说明文档
 ┣ 📂ip_core	//私有IP核 
 ┣ 📂mcs		//工程参数bit和mcs文件
 ┣ 📂src		//仿真、约束、IP核文件
 ┗ 📂tcl		//tcl脚本，工程配置
 	┗ 📜project.tcl	//项目生成脚本
```

## How is it work?

* It use the folder except for `tcl/` and `project/`  as source files then generate the Vivado project at `project/`
* Three branches is in this project :`main` ,`singlecyle` and `pipeline`, remember to delete `project/` or `project_pipeline/` before generating a new one

## How To Use?

### Generate Project
#### Method 1
1. Delete `project/` if exist (It conflicts with new project)<img src="https://cdn.jsdelivr.net/gh/Mark4551124015/Images_Bed/NoteImages/image-20230424202455075.png" alt="image-20230424202455075" style="zoom:20%;"/>
2. Open Vivado 2017.4
3. Click "TCL Console" at Bottom Left
4. Type in command `cd C:/xx/xx/` , `C:/xx/xx/` is the root directory of this document (Project Root) Then Enter 
5. Type in command `source srcs/project.tcl`, Then Enter. Wait for it.
#### Method 2
1. Add vivado to System Variable, you can check this link: [Vivado 环境变量](http://blog.chinaaet.com/crazybird/p/5100000507)
2. Run `generate.bat`

### Modify Project

#### New version:

* just edit in `src/`, but you still need to add them to `project.tcl`

#### old version: (Wont work now)

* You can simply use Vivado as IDE, but export the project by execute `copy.bat`, then commit and push
* Or open `srcs/` by VSCode and edit directly
* `project/` is ignored, won't push to github.

### New File

* While you creating/rename file in `srcs/` you also need to add them into `tcl/project.tcl`, 
  * Because this is the file that generate the project. 

* ip/source/simulation are in different lines in file, you can  find them by key word "Marker"

## 总结

直接在`src/`里写就行了，新建IP核挪到src中，修改`project.tcl`文件即可

现在的project会引用外部的文件