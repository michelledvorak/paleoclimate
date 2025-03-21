;*************************************************
; ice_2.ncl
;
; Concepts illustrated:
;   - Plotting ice data
;   - Adding a missing value (_FillValue)
;   - Drawing curly vectors over a polar stereographic map
;   - Coloring vectors based on magnitude
;   - Changing the length of the vectors
;   - Changing the magnitude of the vectors
;   - Thinning vectors using a minimum distance resource
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************

  e_dir = "/glade/work/mtdvorak/CESM2/SOM/"
  Plio_anom = addfile("/glade/work/mtdvorak/CESM2/SOM/e.e21.PMIP4-midPliocene.piflx.400.WIND.ann_anom.nc","r")
  Plio_280_anom = addfile("/glade/work/mtdvorak/CESM2/SOM/e.e21.PMIP4-midPliocene.piflx.284.7.WIND.ann_anom.nc","r")
  CO2_anom = addfile(e_dir + "e.e21.CMIP6-piControl.new.400.WIND.ann_anom.nc","r")
  Plio_ICE_anom = addfile(e_dir + "e.e21.PMIP4-midPliocene.piflx.400.TEMP.ICE.FORCING.ann_anom.nc","r")
  Plio_280_ICE_anom = addfile(e_dir + "e.e21.PMIP4-midPliocene.piflx.284.7.TEMP.ICE.FORCING.ann_anom.nc","r")
  CO2_ICE_anom = addfile(e_dir + "e.e21.CMIP6-piControl.400.TEMP.ICE.FORCING.ann_anom.nc","r")

  lsm = addfile("/glade/work/mtdvorak/CESM2/Pliocene_mask.nc","r")

  b_dir = "/glade/work/mtdvorak/CESM2/FCM/"

  Plio_U_anom = addfile(b_dir + "b.e21.B1850.f09_g17.PMIP4-midPliocene-eoi400.001.cam.h0.U.ann_anom.nc","r")
  Plio_V_anom = addfile(b_dir + "b.e21.B1850.f09_g17.PMIP4-midPliocene-eoi400.001.cam.h0.V.ann_anom.nc","r")

  Plio_280_U_anom = addfile(b_dir + "b.e21.B1850.f09_g17.PMIP4-midPliocene-eoi400.284.7.cam.h0.U.ann_anom.nc","r")
  Plio_280_V_anom = addfile(b_dir + "b.e21.B1850.f09_g17.PMIP4-midPliocene-eoi400.284.7.cam.h0.V.ann_anom.nc","r")

  CO2_U_anom = addfile(b_dir + "b.e21.B1850.f09_g17.CMIP6-piControl.400.cam.h0.U.ann_anom.nc","r")
  CO2_V_anom = addfile(b_dir + "b.e21.B1850.f09_g17.CMIP6-piControl.400.cam.h0.V.ann_anom.nc","r")

  Plio_ICE_anom_FCM = addfile(b_dir + "b.e21.f09_g17.PMIP4-midPliocene-eoi400.001.cam.h0.ICEFRAC.ann_anom.nc","r")
  Plio_280_ICE_anom_FCM = addfile(b_dir + "b.e21.f09_g17.PMIP4-midPliocene-eoi400.284.7.cam.h0.ICEFRAC.ann_anom.nc","r")
  CO2_ICE_anom_FCM = addfile(b_dir + "b.e21.f09_g17.CMIP6-piControl.400.cam.h0.ICEFRAC.ann_anom.nc","r")

;************************************************
; read in components -- FCM
;************************************************
  u_Plio_FCM = Plio_U_anom->U(0,31,:,:)                            
  v_Plio_FCM = Plio_V_anom->V(0,31,:,:)
  u_Plio_280_FCM = Plio_280_U_anom->U(0,31,:,:)
  v_Plio_280_FCM = Plio_280_V_anom->V(0,31,:,:)
  u_co2_FCM = CO2_U_anom->U(0,31,:,:)
  v_co2_FCM = CO2_V_anom->V(0,31,:,:)

  ICE_Plio_FCM = Plio_ICE_anom_FCM->ICEFRAC(0,:,:)
  ICE_Plio_280_FCM = Plio_280_ICE_anom_FCM->ICEFRAC(0,:,:)
  ICE_CO2_FCM = CO2_ICE_anom_FCM->ICEFRAC(0,:,:)
  land_mask = lsm->mask(:,:)	

;************************************************
; read in components -- SOM
;************************************************

  u_Plio = Plio_anom->U(0,31,:,:)                            
  v_Plio = Plio_anom->V(0,31,:,:)
  u_Plio_280 = Plio_280_anom->U(0,31,:,:)
  v_Plio_280 = Plio_280_anom->V(0,31,:,:)
  u_co2 = CO2_anom->U(0,31,:,:)
  v_co2 = CO2_anom->V(0,31,:,:)

  ICE_Plio = Plio_ICE_anom->ICEFRAC(0,:,:)
  ICE_Plio_280 = Plio_280_ICE_anom->ICEFRAC(0,:,:)
  ICE_CO2 = CO2_ICE_anom->ICEFRAC(0,:,:)

;************************************************
; this data only has an missing_value, so we are
; copying this to _FillValue for plotting purposes
;************************************************
;  assignFillValue(v_diff,u_diff)                           ; in contributed      
;  assignFillValue(u_diff,v_diff)
;************************************************
; create plot
;************************************************
  wks  = gsn_open_wks("pdf" ,"ICE_plus_wind_set_ALL_linevec")              ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200") ; choose colormap
  cmap2 = read_colormap_file("precip4_diff_19lev")
  plot = new(6,graphic)

  res            = True                         ; plot mods desired
  res@gsnDraw = False
  res@gsnFrame = False
  res@gsnPolarSH = True                         ; specify the hemisphere
  res@lbLabelBarOn = False

  res@cnLinesOn = False
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = -1
  res@cnMaxLevelValF = 1
  res@cnLevelSpacingF = 0.1
  res@tiMainString = ""
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@gsnCenterStringFontHeightF = 0.035
  res@gsnPolarLabelFontHeightF = 0.025

;--- map adjustments

  res@mpMaxLatF  = -50                           ; minimum lat to plot
  res@mpFillOn = False			 ; turn off map fill
;  res@mpGridlLineThicknessF = 0.08	; reduce grid line thickness
  res@mpOutlineOn = False

;-- Contour line adjustments

  res@cnFillOn   = True
  res@cnFillPalette = cmap2

;-- Overlay land-sea mask
 
  lsmres = True
  lsmres@gsnDraw = False
  lsmres@gsnFrame = False
  lsmres@gsnLeftString = ""
  lsmres@cnLevelSpacingF = 0.9
;  lsmres@gsLineThicknessF = 0.1
  lsmres@cnLineLabelsOn = False
  lsmres@cnInfoLabelOn = False
 
  vecres = True
  vecres@gsnDraw = False
  vecres@gsnFrame = False
;  vecres@gsnPolarSH = True
;  vecres@mpMaxLatF = -50
  vecres@gsnLeftString = ""
  vecres@gsnRightString = ""
  vecres@vcLevelPalette        = cmap(18:191,:)   ; subset color map
  vecres@vcRefMagnitudeF       = 5.0              ; vec magnitude
  vecres@vcRefLengthF          = 0.05            ; size of ref vector

  vecres@vcRefAnnoOn = False
  vecres@vcMonoLineArrowColor  = True             ; vectors color by magnitude
  vecres@vcLineArrowColor = "darkslategrey"
  vecres@vcMinDistanceF        = 0.02              ; thins arrows near pole
  vecres@vcGlyphStyle          = "LineArrow"    ; curly vectors on
  vecres@vcLineArrowThicknessF = 1.2

  res@gsnCenterString = "FCM-mPWP"
  plotA = gsn_csm_contour_map_polar(wks,ICE_Plio_FCM,res)
  plotB = gsn_csm_vector(wks,u_Plio_FCM,v_Plio_FCM,vecres)
  lsm_coastlines = gsn_csm_contour(wks, land_mask, lsmres)
  overlay(plotA,plotB)
  overlay(plotA,lsm_coastlines)

  plot(0) = plotA

  res@gsnCenterString = "FCM-BC" 
  plotC = gsn_csm_contour_map_polar(wks,ICE_Plio_280_FCM,res)
  plotD = gsn_csm_vector(wks,u_Plio_280_FCM,v_Plio_280_FCM,vecres)
  lsm_coastlines = gsn_csm_contour(wks, land_mask, lsmres)
  overlay(plotC,plotD)
  overlay(plotC,lsm_coastlines)

  plot(1) = plotC

  res@mpOutlineOn = True

  res@gsnCenterString = "FCM-CO~B~2" 
  plotE = gsn_csm_contour_map_polar(wks,ICE_CO2_FCM,res)
  plotF = gsn_csm_vector(wks,u_co2_FCM,v_co2_FCM,vecres)
  overlay(plotE,plotF)

  plot(2) = plotE

  res@mpOutlineOn = False

  res@gsnCenterString = "SOM-mPWP"
  plotG = gsn_csm_contour_map_polar(wks,ICE_Plio,res)
  plotH = gsn_csm_vector(wks,u_Plio,v_Plio,vecres)
  lsm_coastlines = gsn_csm_contour(wks, land_mask, lsmres)
  overlay(plotG,plotH)
  overlay(plotG,lsm_coastlines)

  plot(3)= plotG

  res@gsnCenterString = "SOM-BC" 
  plotI = gsn_csm_contour_map_polar(wks,ICE_Plio_280,res)
  plotJ = gsn_csm_vector(wks,u_Plio_280,v_Plio_280,vecres)
  lsm_coastlines = gsn_csm_contour(wks, land_mask, lsmres)
  overlay(plotI,plotJ)
  overlay(plotI,lsm_coastlines)

  plot(4) = plotI

  res@mpOutlineOn = True
  vecres@vcRefAnnoOn = True
  vecres@vcRefAnnoFontHeightF = 0.025
  vecres@vcRefAnnoPerimOn = False
  vecres@vcRefAnnoString1 = "$VMG$ ms~S~-1"
  vecres@vcRefAnnoString2On = False

  res@gsnCenterString = "SOM-CO~B~2" 
  plotJ = gsn_csm_contour_map_polar(wks,ICE_CO2,res)
  plotK = gsn_csm_vector(wks,u_co2,v_co2,vecres)
  overlay(plotJ,plotK)

  plot(5) = plotJ

;*****************************************
; create panel resources
;*****************************************

  pres = True
  pres@gsnPanelLabelBar = True
  pres@lbLabelStride = 2

  pres@lbTitleOn = True
  pres@lbTitleString = "sea ice fraction anomaly"
  pres@lbTitleFontHeightF = 0.018
;  pres@lbTitlePosition = "Right"
  pres@lbTitleDirection = "Across"
  pres@lbLabelFontHeightF = 0.012
  
  pres@gsnPanelFigureStrings= (/"a","b","c","d","e","f"/) ; add strings to panel
  pres@gsnPanelFigureStringsFont = "helvetica-bold"
;  pres@amJust   = "TopLeft"
  pres@gsFontThicknessF = 1.2
  pres@amParallelPosF = -0.55
  pres@amOrthogonalPosF = -0.54

  pres@gsnPanelFigureStringsFontHeightF = 0.014
  pres@gsnPanelFigureStringsFontThicknessF = 5.0
  pres@gsnPanelFigureStringsPerimOn = False
 
  gsn_panel(wks,plot,(/2,3/),pres)


end

