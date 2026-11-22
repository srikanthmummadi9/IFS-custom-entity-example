layer Cust;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     c_equipment_rental_rate_tab%ROWTYPE,
   newrec_ IN OUT c_equipment_rental_rate_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   overlap_count_ NUMBER;
   CURSOR get_overlap IS
      SELECT COUNT(*)
      FROM   c_equipment_rental_rate_tab t
      WHERE  t.contract       = newrec_.contract
      AND    t.vendor_no      = newrec_.vendor_no
      AND    t.equipment_type = newrec_.equipment_type
      AND    t.valid_from    != newrec_.valid_from
      AND    t.valid_from    <= NVL(newrec_.valid_to, DATE '9999-12-31')
      AND    NVL(t.valid_to, DATE '9999-12-31') >= newrec_.valid_from;
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);

   IF newrec_.rental_rate IS NULL OR newrec_.rental_rate <= 0 THEN
      Error_SYS.Record_General(lu_name_, 'RATEPOS: Rental rate must be greater than zero.');
   END IF;

   IF newrec_.valid_to IS NOT NULL AND newrec_.valid_to < newrec_.valid_from THEN
      Error_SYS.Record_General(lu_name_, 'DATEORDER: Valid To cannot be earlier than Valid From.');
   END IF;

   OPEN get_overlap;
   FETCH get_overlap INTO overlap_count_;
   CLOSE get_overlap;
   IF overlap_count_ > 0 THEN
      Error_SYS.Record_General(lu_name_, 'OVERLAP: A rate already exists for this site, supplier and equipment type in the same period.');
   END IF;
END Check_Common___;
