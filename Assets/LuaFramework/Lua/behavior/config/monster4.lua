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
    }
  }
}
return __bt__