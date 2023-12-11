local __bt__ = {
  file= "rootNode",
  data= {
    restart= 1
  },
  children= {
    {
      file= "selectorNode",
      type= "composites/selectorNode",
      data= {
        abort= "None"
      },
      children= {
        {
          file= "parallelNode",
          type= "composites/parallelNode",
          data= {
            abort= "None"
          },
          children= {
            {
              file= "logNode",
              type= "actions/common/logNode",
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
              file= "logNode",
              type= "actions/common/logNode",
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