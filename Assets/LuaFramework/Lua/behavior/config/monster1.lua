local __bt__ = {
  file= "rootNode",
  type= "",
  data= {
    restart= 1
  },
  children= {
    {
      file= "sequenceNode",
      type= "composites/sequenceNode",
      data= {
        abort= "None"
      },
      children= {
        {
          file= "weightNode",
          type= "actions/common/weightNode",
          data= {
            weight= 500
          },
        },
        {
          file= "waitNode",
          type= "actions/common/waitNode",
          data= {
            min_time= 1,
            max_time= 3
          },
        }
      }
    }
  }
}
return __bt__