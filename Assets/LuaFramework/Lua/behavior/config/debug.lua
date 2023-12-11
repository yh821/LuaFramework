local __bt__ = {
  file= "rootNode",
  type= "",
  data= {
    restart= 1
  },
  children= {
    {
      file= "parallelNode",
      type= "composites/parallelNode",
      children= {
        {
          file= "logNode",
          type= "actions/common/logNode",
        },
        {
          file= "logNode",
          type= "actions/common/logNode",
        },
        {
          file= "logNode",
          type= "actions/common/logNode",
        }
      }
    }
  }
}
return __bt__