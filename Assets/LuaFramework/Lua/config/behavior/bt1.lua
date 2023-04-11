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
            abort= "Both"
          },
          children= {
            {
              file= "waitNode",
              type= "actions/common/waitNode",
              data= {
                min_time= 1,
                max_time= 1
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
              file= "isActiveNode",
              type= "conditions/isActiveNode",
              data= {
                path= "Open"
              },
            },
            {
              file= "sequenceNode",
              type= "composites/sequenceNode",
              data= {
                abort= "Both"
              },
              children= {
                {
                  file= "sequenceNode",
                  type= "composites/sequenceNode",
                  data= {
                    abort= "Both"
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
                      file= "waitNode",
                      type= "actions/common/waitNode",
                      data= {
                        min_time= 1,
                        max_time= 1
                      },
                    }
                  }
                },
                {
                  file= "waitNode",
                  type= "actions/common/waitNode",
                  data= {
                    min_time= 1,
                    max_time= 1
                  },
                }
              }
            },
            {
              file= "waitNode",
              type= "actions/common/waitNode",
              data= {
                min_time= 1,
                max_time= 1
              },
            }
          }
        },
        {
          file= "selectorNode",
          type= "composites/selectorNode",
          data= {
            abort= "Both"
          },
          children= {
            {
              file= "isActiveNode",
              type= "conditions/isActiveNode",
              data= {
                path= "BottomHint"
              },
            },
            {
              file= "sequenceNode",
              type= "composites/sequenceNode",
              data= {
                abort= "None"
              },
              children= {
                {
                  file= "waitNode",
                  type= "actions/common/waitNode",
                  data= {
                    min_time= 1,
                    max_time= 1
                  },
                },
                {
                  file= "waitNode",
                  type= "actions/common/waitNode",
                  data= {
                    min_time= 1,
                    max_time= 1
                  },
                }
              }
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
              file= "isActiveNode",
              type= "conditions/isActiveNode",
              data= {
                path= "ScrollView"
              },
            },
            {
              file= "waitNode",
              type= "actions/common/waitNode",
              data= {
                min_time= 1,
                max_time= 1
              },
            }
          }
        }
      }
    }
  }
}
return __bt__