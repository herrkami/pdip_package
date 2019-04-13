# PDIP Package Creator

OpenSCAD file/library to generate PDIP packages. It intentionally only generates the shape of the package, not a label, color, or anything. I found three different package widths that are selectable with the `package_type` keyword.

E.g., to generate a standard 8-pin package, like that of your favorite 555, call
```openscad
pdip_package(nr_legs=8, package_type=0);
```

![pdip_animation.gif](gif/pdip_animation.gif)
