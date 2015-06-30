/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
��U S E   [ a n i m a l ]  
 G O  
 / * * * * * *   O b j e c t :     U s e r D e f i n e d F u n c t i o n   [ d b o ] . [ f _ i s N u m e r i c ]         S c r i p t   D a t e :   6 / 1 9 / 2 0 1 5   9 : 5 9 : 2 8   A M   * * * * * * /  
 S E T   A N S I _ N U L L S   O N  
 G O  
 S E T   Q U O T E D _ I D E N T I F I E R   O N  
 G O  
 - -   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  
 - -   A u t h o r : 	 	 T e r r y   H a w k i n s  
 - -   C r e a t e   d a t e :   2 / 2 8 / 1 4  
 - -   D e s c r i p t i o n : 	 R e t u r n s   1   i f   t h e   v a l u e   i s   n u m e r i c ,   0   i f   v a l u e   i s   n o t   n u m e r i c  
 - -   6 / 1 9 / 2 0 1 5 	 a d d e d   a d d i t i o n a l   c r i t e r i a   b a s e d   o n   t h e   c u r r e n t   d a t a s e t s .   t j h  
 - -   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  
 A L T E R   F U N C T I O N   [ d b o ] . [ f _ i s N u m e r i c ]  
 (  
 	 @ v a l u e   V A R C H A R ( M A X )  
 )  
 R E T U R N S   I N T  
 A S  
 B E G I N  
 	 - -   D e c l a r e   t h e   r e t u r n   v a r i a b l e   h e r e  
 	 D E C L A R E   @ r e t u r n   I N T  
  
  
 	 I F   ( @ v a l u e   I S   N U L L )    
 	 B E G I N  
 	 	 S E T   @ r e t u r n   =   0  
 	 	 G O T O   f i n i s  
 	 E N D  
  
 	          
 	 s e l e c t   @ v a l u e   =     L T R I M ( R T R I M ( R E P L A C E ( @ v a l u e ,   '   ' ,   ' ' ) ) )  
  
 	 I F   P A T I N D E X ( ' % [ ^ 0 - 9 . - + ] % ' ,   @ v a l u e )   =   0  
 	 b e g i n  
  
 	 	 I F   ( I S N U M E R I C ( @ v a l u e )   =   1 )  
 	 	 B E G I N  
 	 	 	 i f     (   L E N ( @ v a l u e )   =   1   A N D     C H A R I N D E X   ( ' + ' ,   @ v a l u e ,   1 )   >   0 )    
 	 	 	 O R   (   L E N ( @ v a l u e )   =   1   A N D   C H A R I N D E X ( ' - ' ,   @ v a l u e ,   1 )   >   0 )  
 	 	    
 	 	 	 B E G I N    
 	 	 	 	 S E T   @ r e t u r n   =   0  
 	 	 	 	 G O T O   f i n i s  
 	 	 	 E N D    
  
 	 	 	 S E T   @ r e t u r n   =   1 	  
 	 	 	 G O T O   f i n i s  
 	 	 	 	  
 	 	 E N D    
 	 E L S E  
 	 	 S E T   @ r e t u r n   =   0  
 	 	 G O T O   f i n i s  
 	 E N D    
 	  
 	 S E T   @ r e t u r n   =   0  
  
 	  
  
 f i n i s :  
 	 R E T U R N   @ r e t u r n  
  
 E N D  
 