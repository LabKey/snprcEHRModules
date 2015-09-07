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
��/ *  
   *   C o p y r i g h t   ( c )   2 0 1 5   L a b K e y   C o r p o r a t i o n  
   *  
   *   L i c e n s e d   u n d e r   t h e   A p a c h e   L i c e n s e ,   V e r s i o n   2 . 0   ( t h e   " L i c e n s e " ) ;  
   *   y o u   m a y   n o t   u s e   t h i s   f i l e   e x c e p t   i n   c o m p l i a n c e   w i t h   t h e   L i c e n s e .  
   *   Y o u   m a y   o b t a i n   a   c o p y   o f   t h e   L i c e n s e   a t  
   *  
   *           h t t p : / / w w w . a p a c h e . o r g / l i c e n s e s / L I C E N S E - 2 . 0  
   *  
   *   U n l e s s   r e q u i r e d   b y   a p p l i c a b l e   l a w   o r   a g r e e d   t o   i n   w r i t i n g ,   s o f t w a r e  
   *   d i s t r i b u t e d   u n d e r   t h e   L i c e n s e   i s   d i s t r i b u t e d   o n   a n   " A S   I S "   B A S I S ,  
   *   W I T H O U T   W A R R A N T I E S   O R   C O N D I T I O N S   O F   A N Y   K I N D ,   e i t h e r   e x p r e s s   o r   i m p l i e d .  
   *   S e e   t h e   L i c e n s e   f o r   t h e   s p e c i f i c   l a n g u a g e   g o v e r n i n g   p e r m i s s i o n s   a n d  
   *   l i m i t a t i o n s   u n d e r   t h e   L i c e n s e .  
   * /  
 U S E   [ a n i m a l ]  
 G O  
  
 S E T   A N S I _ N U L L S   O N  
 G O  
  
 S E T   Q U O T E D _ I D E N T I F I E R   O N  
 G O  
  
 / * = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = * /  
 / *   V i e w :   v _ a n i m a l _ g r o u p _ m e m b e r s                                                                   * /  
 / * = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = * /  
 A L T E R   V I E W   [ l a b k e y _ e t l ] . [ V _ p r e g n a n c y _ c o n f i r m a t i o n ]   a s  
 - -   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  
 - -   A u t h o r :   T e r r y   H a w k i n s  
 - -   C r e a t e   d a t e :   8 / 3 1 / 2 0 1 5  
 - -  
 - -    
 - -   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  
  
  
   S E L E C T   e d c . i d   A S   i d   ,  
 	 	 e d c . e d c   A S   d a t e ,  
 	 	 L T R I M ( R T R I M ( e d c . s i r e _ i d ) )   A S   s i r e ,  
                 e d c . t e r m _ d a t e   A S   t e r m D a t e ,  
                 e d c . t e r m _ c o d e   A S   t e r m C o d e ,  
                 e d c . c o n f i r m _ d a t e   A S   c o n f i r m D a t e ,  
 	 	 e d c . l a s t _ o b s c a n _ d a t e   A S   l a s t O b s c a n D a t e ,  
 	 	 e d c . o b j e c t _ i d   A S   o b j e c t i d ,  
                 e d c . u s e r _ n a m e   ,  
                 e d c . e n t r y _ d a t e _ t m   ,  
                 e d c . t i m e s t a m p  
   F R O M   d b o . e d c   A S   e d c  
   I N N E R   J O I N   l a b k e y _ e t l . V _ D E M O G R A P H I C S   A S   d   O N   d . i d   =   e d c . i d  
  
  
 G O  
  
 g r a n t   S E L E C T   o n   l a b k e y _ e t l . V _ P R E G N A N C Y _ C O N F I R M A T I O N   t o   z _ l a b k e y  
  
 g o 