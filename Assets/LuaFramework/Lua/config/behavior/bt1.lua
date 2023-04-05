local __bt__ = {
  file= "rootNode",
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
                },
                {
                  file= "waitNode",
                  type= "actions/common/waitNode",
                  data= {
                    min_time= 1,
                    max_time= 3
                  },
                },
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
        },
        {
          file= "waitNode",
          type= "actions/common/waitNode",
          data= {
            min_time= 1,
            max_time= 3
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