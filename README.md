This is a graphics toolchain for creating Factorio-compatible rail graphics.
It supports both Factorio 1.0 and Factorio 2.0 styles.

Instructions:

- Install OpenSCAD. This is a free tool to programmatically do CAD modelling.

- Edit generator.scad to make whatever rail shape you want.
    Make sure to change factorio_version = "1.1"; if you are making rail graphics for Factorio 2.0

- Run export_all_scad.ps1
    This file will convert all .scad files into the directory into blender-compatible .stl files.

- Import all .stl files into the blender project I have created. Delete all the .stl files that are pre-existing.
    IMPORTANT: Make sure to use the legacy STL import not the modern one.

- Set the "generator" object as a holdout. This will generate your shadow. 

- Edit the position of the shadow catcher.

- Render each object seperately and save their .png output to this directory.

- Run splitter.py to automatically convert the .png files into factorio spritesheets.
    You must also change the output_path variable in the python code.

- Import the resulting spritesheets into Factorio. I have provided example code in the lua-example directory.

I used openscad v2021.01 and Blender v4.1.