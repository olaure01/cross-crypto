Set Implicit Arguments.
Unset Strict Implicit.

Require Import Omega.
Require Import CrossCrypto.FrapTactics.
Require Import CrossCrypto.ListUtil.
Require Import CrossCrypto.Tuple.
Require Import Coq.Lists.List.
Import ListNotations.

Inductive hlist A (f : A -> Type) : list A -> Type :=
| hnil : hlist f []
| hcons : forall x l, f x -> hlist f l -> hlist f (x :: l).

Notation " h[] " := (hnil _).
Infix "h::" := hcons (at level 60, right associativity).

Definition hhead A f (l : list A) (hl : hlist f l) (H : l <> []) : f (head_with_proof H).
  inversion hl.
  congruence.
  subst l.
  simpl.
  exact X.
Defined.

Definition htail A f (l : list A) (hl : hlist f l) : hlist f (tl l).
  cases l.
  exact h[].
  inversion hl.
  exact X0.
Defined.

Fixpoint list2hlist T (A : T) (f : T -> Type) (fl : list (f A)) : hlist f (repeat A (length fl)).
  cases fl.
  exact (h[]).
  exact (f0 h:: list2hlist T A f fl).
Defined.

Fixpoint hlist2list A (f : A -> Type) l (hl : hlist f l) (x : A) (H : exists n , l = repeat x n) : list (f x).
  cases hl.
  exact [].
  refine (_ :: hlist2list A f l hl x _).
  assert (x = x0).
  destruct H.
  cases x1.
  simplify.
  equality.
  unfold repeat in H.
  equality.
  subst x.
  exact f0.
  destruct H.
  cases x1.
  simplify.
  equality.
  exists x1.
  unfold repeat in H.
  assert (x = x0).
  equality.
  subst x.
  unfold repeat.
  equality.
Defined.

Fixpoint tuple2hlist A (T : A) P n (t : tuple (P T) n)
: hlist P (repeat T n).
  induction t; constructor; assumption.
Defined.

Lemma hlist2list_len : forall A (f : A -> Type) (l : list A) (hl : hlist f l) (x : A) (P : exists n, l = repeat x n), length (hlist2list hl P) = length l.
Proof.
  induct hl; simplify; equality.
Qed.

Definition hlist2tuple (A : Type) (f : A -> Type) (l : list A) (hl : hlist f l) (x : A) n (P : l = repeat x n) : tuple (f x) n.
  assert (exists n0 : nat, l = repeat x n0).
  exists n.
  assumption.
  assert (n = length (hlist2list hl (x:=x) H)).
  assert (length (hlist2list hl (x:=x) H) = length l).
  apply hlist2list_len.
  rewrite H0.
  rewrite P.
  Locate repeat.
  symmetry.
  apply repeat_length.
  rewrite H0.
  exact (list2tuple (hlist2list hl H)).
Defined.
        
Definition hmap A (f : A -> Type) B (g : B -> Type)
           (F : A -> B) (F' : forall a, f a -> g (F a))
           (l : list A) (h : hlist f l) : hlist g (map F l).
  induction h; constructor; auto.
Defined.

Definition hmap' A (f : A -> Type) (g : A -> Type)
           (F' : forall a, f a -> g a)
           (l : list A) (h : hlist f l) : hlist g l.
  replace l with (map id l).
  apply hmap with (f := f); assumption.
  clear f g F' h.
  induction l as [| x xs IHl]; [| simpl; rewrite IHl]; reflexivity.
Defined.
