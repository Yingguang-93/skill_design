;//////////////////////////////////////////////////////////////////////////////
;//       Cadence Design Systems
;//
;// (C) COPYRIGHT, Cadence Design Systems, Inc. 2004
;// All Rights Reserved
;// Licensed Materials - Property of Cadence Design Systems
;//
;// No part of this file may be reproduced, stored in a retrieval system,
;// or transmitted in any form or by any means --- electronic, mechanical,
;// photocopying, recording, or otherwise --- without prior written permission
;// of Cadence Design Systems, Inc.
;//
;// WARRANTY:
;// Use all material in this file at your own risk.  Cadence Design Systems
;// makes no claims about any material contained in this file.
;// 
;// NOTE: This code is unsupported.
;//
;//////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////
;// SKILL file - Skill command to remove fillet properties on clines that 
;//              are not actually fillets. 
;//////////////////////////////////////////////////////////////////////////////

;//////////////////////////////////////////////////////////////////////////////
;// Name: strip_bad_fillet_props()                                           //
;// Input: Nothing (whole design)                                            //
;// Output: Nothing (walks and updates design).                              //
;// Description:                                                             //
;//   Walks all the CLines in the current database and looks for clines with //
;//   the fillet property that are not likely fillets. That is, clines which //
;//   start at a T, via, or pin but are not dangling.                        //
;//////////////////////////////////////////////////////////////////////////////
procedure( strip_bad_fillet_props()
let( (fp sortList pinList success delay)

    foreach(net axlDBGetDesign()->nets
        foreach(branch net->branches
            foreach(item branch->children

                when("path" == item->objType && !strip_is_real_fillet(item)
                    axlDBDeleteProp(item list("FILLET"))
                );//when

            );//foreach
        );//foreach
    );//foreach
    
    t;

))

;//////////////////////////////////////////////////////////////////////////////
;// Name: strip_is_real_fillet()                                             //
;// Input: Cline to check                                                    //
;// Output: Whether or not it's a true fillet.                               //
;// Description:                                                             //
;//   Check to make sure a cline is a real fillet, not a cline with a        //
;//   fillet property that shouldn't be there.                               //
;//////////////////////////////////////////////////////////////////////////////
procedure( strip_is_real_fillet(cline)
let((fillet result connect1 connect2)

   when(cline->objType == "path" && 
        cline->prop->FILLET && 
        onep(cline->nSegs) && 
        (result = axlDBGetConnect(cline))

      foreach(object car(result)
         case(object->objType ("pin" || "via" || "shape" || "tee" connect1 = t));//case
      );//foreach

      foreach(object cadr(result)
         case(object->objType ("pin" || "via" || "shape" || "tee" connect2 = t));//case
      );//foreach

      fillet = (connect1 != connect2);

   );//when

   fillet
));
axlCmdRegister("fillet_check" 'strip_bad_fillet_props)