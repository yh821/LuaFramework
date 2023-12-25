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
            abort= "Lower"
          },
          children= {
            {
              file= "isInViewNode",
              type= "conditions/isInViewNode",
              data= {
                ViewRange= 3
              },
            },
            {
              file= "moveToPositionNode",
              type= "actions/moveToPositionNode",
              data= {
                pos= "TargetPos"
              },
            },
            {
              file= "attackNode",
              type= "actions/attackNode",
              data= {
                pos= "TargetPos"
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
                center= "0,0,0",
                range= 5
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
}
return __bt__