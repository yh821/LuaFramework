local __bt__ = {
  file= "rootNode",
  data= {
    restart= 1
  },
  children= {
    {
      file= "selectorNode",
      type= "composites/selectorNode",
      children= {
        {
          file= "parallelNode",
          type= "composites/parallelNode",
          data= {
            abort= "None"
          },
          children= {
            {
              file= "LogNode",
              type= "actions/common/LogNode",
              data= {
                msg= 111
              },
            }
          }
        },
        {
          file= "parallelNode",
          type= "composites/parallelNode",
          data= {
            abort= "None"
          },
          children= {
            {
              file= "LogNode",
              type= "actions/common/LogNode",
              data= {
                msg= 222
              },
            }
          }
        }
      }
    }
  }
}
return __bt__