local __bt__ = {
  file= "rootNode",
  type= "",
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
          file= "sequenceNode",
          type= "composites/sequenceNode",
          data= {
            abort= "Self"
          },
          children= {
            {
              file= "isActiveNode",
              type= "conditions/isActiveNode",
              data= {
                path= "Label"
              },
            },
            {
              file= "logNode",
              type= "actions/common/logNode",
              data= {
                msg= 111
              },
            },
            {
              file= "waitNode",
              type= "actions/common/waitNode",
              data= {
                min_time= 2,
                max_time= 2
              },
            }
          }
        },
        {
          file= "sequenceNode",
          type= "composites/sequenceNode",
          data= {
            abort= "Lower"
          },
          children= {
            {
              file= "logNode",
              type= "actions/common/logNode",
              data= {
                msg= 222
              },
            },
            {
              file= "isActiveNode",
              type= "conditions/isActiveNode",
              data= {
                path= "Sprite"
              },
            },
            {
              file= "waitNode",
              type= "actions/common/waitNode",
              data= {
                min_time= 2,
                max_time= 2
              },
            }
          }
        },
        {
          file= "sequenceNode",
          type= "composites/sequenceNode",
          data= {
            abort= "None"
          },
          children= {
            {
              file= "logNode",
              type= "actions/common/logNode",
              data= {
                msg= 333
              },
            },
            {
              file= "waitNode",
              type= "actions/common/waitNode",
              data= {
                min_time= 2,
                max_time= 2
              },
            },
            {
              file= "logNode",
              type= "actions/common/logNode",
              data= {
                msg= 444
              },
            }
          }
        }
      }
    }
  }
}
return __bt__