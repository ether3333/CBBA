Based on the original CBBA code, I created 4 files;
Simple_Main, Simple_Init, Simple_Bundle, Simple_Plot.
The purpose of creation is to understand each files' functions more clearly.
I created flow of each files below to help understanding of the codes.

```
Simple_Main.m
   ├── Simple_Init.m
   │       └── (initialize # of agent, # of task, and task type)
   │
   ├── Simple_Bundle.m
   │       ├── [Algorithm 2] Communicate 
   │       │        (consensus of winner & bidding between agents)
   │       ├── [Algorithm 1 + part of Algorithm 3] 
   │       │        BundleRemove & BundleAdd 
   │       │        (Compare bid --> remove task --> update bundle)
   │       └── [Algorithm 3] Convergence Check & Calculate result
   │
   └── Simple_Plot.m
           └── (visualize result)
```
