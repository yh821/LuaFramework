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
              file= "isInViewNode",
              type= "conditions/isInViewNode",
              data= {
                ViewRange= 12
              },
            },
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
                },
                {
                  file= "sequenceNode",
                  type= "composites/sequenceNode",
                  data= {
                    abort= "None"
                  },
                  children= {
                    {
                      file= "randomPositionNode",
                      type= "actions/randomPositionNode",
                      data= {
                        center= "TargetPos"
                      },
                    },
                    {
                      file= "moveToPositionNode",
                      type= "actions/moveToPositionNode",
                      data= {
                        pos= "RandomPos"
                      },
                    }
                  }
                }
              }
            }
          }
        },
        {
          file= "moveToPositionNode",
          type= "actions/moveToPositionNode",
          data= {
            pos= "TargetPos"
          },
        }
      }
    }
  }
}
return __bt__